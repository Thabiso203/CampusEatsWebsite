// src/routes/orders.js
const express = require('express');
const { pool, withTransaction } = require('../config/db');
const { verifyToken, requireCustomer } = require('../middleware/auth');
const { notifyStaffOfNewOrder } = require('../utils/sms');

const router = express.Router();

const SERVICE_FEE_PERCENT = Number(process.env.SERVICE_FEE_PERCENT || 10);

// ------------------------------------------------------------
// POST /api/orders/:id/feedback — one rating per delivered order.
// Feedback is stored against the authenticated customer and order.
// ------------------------------------------------------------
router.post('/:id/feedback', verifyToken, requireCustomer, async (req, res) => {
  const rating = Number(req.body.rating);
  const comment = typeof req.body.comment === 'string' ? req.body.comment.trim() : '';

  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    return res.status(400).json({ error: 'Rating must be a whole number from 1 to 5.' });
  }
  if (comment.length > 1000) {
    return res.status(400).json({ error: 'Feedback must be 1000 characters or fewer.' });
  }

  try {
    const orderResult = await pool.query(
      'SELECT id FROM orders WHERE id = $1 AND customer_id = $2 AND status = $3',
      [req.params.id, req.user.id, 'delivered']
    );
    if (orderResult.rowCount === 0) {
      return res.status(409).json({ error: 'Feedback is available only for your delivered orders.' });
    }

    const result = await pool.query(
      `INSERT INTO order_feedback (order_id, customer_id, rating, comment)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (order_id) DO NOTHING
       RETURNING order_id, rating, comment, created_at`,
      [req.params.id, req.user.id, rating, comment || null]
    );

    if (result.rowCount === 0) {
      return res.status(409).json({ error: 'Feedback has already been submitted for this order.' });
    }
    return res.status(201).json({ feedback: result.rows[0], message: 'Thank you for your feedback!' });
  } catch (err) {
    console.error('submit order feedback error', err);
    return res.status(500).json({ error: 'Failed to save feedback. Please try again.' });
  }
});


// ------------------------------------------------------------
// POST /api/orders
// Body: { buildingId, roomNumber, paymentMethod, items: [{ menuItemId, quantity }] }
//
// SECURITY NOTE: the client sends WHAT was ordered (item ids + quantities),
// never how much it costs. Every price is re-looked-up from menu_items and
// the subtotal / fee / total are computed here. A tampered "total" field
// in the request body is simply ignored.
// ------------------------------------------------------------
router.post('/', verifyToken, requireCustomer, async (req, res) => {
  const { buildingId, roomNumber, paymentMethod, items } = req.body;
  const orderNotes = typeof req.body.orderNotes === "string" ? req.body.orderNotes.trim() : "";
  if (orderNotes.length > 300) {
    return res.status(400).json({ error: "Order instructions must be 300 characters or fewer." });
  }

  if (!buildingId || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'buildingId and at least one item are required' });
  }
  if (paymentMethod && !['cash', 'bank_transfer'].includes(paymentMethod)) {
    return res.status(400).json({ error: 'paymentMethod must be cash or bank_transfer' });
  }

  // Basic shape validation on each line item before we hit the DB.
  for (const item of items) {
    if (!item.menuItemId || !Number.isInteger(item.quantity) || item.quantity <= 0) {
      return res.status(400).json({ error: 'Each item needs a menuItemId and a positive integer quantity' });
    }
  }

  try {
    const order = await withTransaction(async (client) => {
      // Confirm building exists and is active.
      const buildingResult = await client.query(
        'SELECT id, name FROM buildings WHERE id = $1 AND is_active = TRUE',
        [buildingId]
      );
      if (buildingResult.rowCount === 0) {
        const err = new Error('Building not found or inactive');
        err.statusCode = 400;
        throw err;
      }
      const building = buildingResult.rows[0];

      // Look up authoritative prices for every requested item in one query.
      const menuItemIds = items.map((i) => i.menuItemId);
      const priceResult = await client.query(
        `SELECT id, name, price_cents, is_available FROM menu_items WHERE id = ANY($1::uuid[])`,
        [menuItemIds]
      );
      const priceById = new Map(priceResult.rows.map((row) => [row.id, row]));

      let subtotalCents = 0;
      const lineItems = [];

      for (const requested of items) {
        const menuItem = priceById.get(requested.menuItemId);
        if (!menuItem) {
          const err = new Error(`Menu item ${requested.menuItemId} not found`);
          err.statusCode = 400;
          throw err;
        }
        if (!menuItem.is_available) {
          const err = new Error(`"${menuItem.name}" is currently unavailable`);
          err.statusCode = 400;
          throw err;
        }

        const lineTotal = menuItem.price_cents * requested.quantity;
        subtotalCents += lineTotal;

        lineItems.push({
          menuItemId: menuItem.id,
          itemName: menuItem.name,
          unitPriceCents: menuItem.price_cents,
          quantity: requested.quantity,
          lineTotalCents: lineTotal,
        });
      }

      // Server-computed fee — the ONLY place the 10% figure is applied.
      const feeCents = Math.round((subtotalCents * SERVICE_FEE_PERCENT) / 100);
      const totalCents = subtotalCents + feeCents;

      const orderResult = await client.query(
        `INSERT INTO orders
           (customer_id, building_id, room_number, subtotal_cents, fee_cents, total_cents, payment_method, order_notes, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending')
         RETURNING *`,
        [
          req.user.id,
          buildingId,
          roomNumber || null,
          subtotalCents,
          feeCents,
          totalCents,
          paymentMethod || 'cash',
          orderNotes || null,
        ]
      );
      const newOrder = orderResult.rows[0];

      // Bulk-insert order items.
      const insertValues = [];
      const placeholders = lineItems
        .map((item, idx) => {
          const base = idx * 5;
          insertValues.push(
            newOrder.id,
            item.menuItemId,
            item.itemName,
            item.unitPriceCents,
            item.quantity
          );
          return `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5}, $${base + 4}::int * $${base + 5}::int)`;
        })
        .join(', ');

      await client.query(
        `INSERT INTO order_items (order_id, menu_item_id, item_name, unit_price_cents, quantity, line_total_cents)
         VALUES ${placeholders}`,
        insertValues
      );

      return { ...newOrder, buildingName: building.name, items: lineItems };
    });

    // Fire the SMS notification after the transaction commits — a failed
    // SMS should never roll back a successfully placed order.
    notifyStaffOfNewOrder({
      id: order.id,
      buildingName: order.buildingName,
      totalCents: order.total_cents,
    }).catch((err) => console.error('SMS notify failed', err));

    res.status(201).json({ order });
  } catch (err) {
    console.error('create order error', err);
    res.status(err.statusCode || 500).json({ error: err.statusCode ? err.message : 'Failed to create order' });
  }
});

// ------------------------------------------------------------
// POST /api/orders/:id/cancel — customers may cancel only their own pending orders.
// The conditional UPDATE is atomic, so it cannot cancel an order staff accepted first.
// ------------------------------------------------------------
router.post('/:id/cancel', verifyToken, requireCustomer, async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE orders
       SET status = 'cancelled'
       WHERE id = $1 AND customer_id = $2 AND status = 'pending'
       RETURNING id, status`,
      [req.params.id, req.user.id]
    );

    if (result.rowCount === 1) {
      return res.json({ order: result.rows[0], message: 'Order cancelled' });
    }

    const existing = await pool.query(
      'SELECT status FROM orders WHERE id = $1 AND customer_id = $2',
      [req.params.id, req.user.id]
    );
    if (existing.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    return res.status(409).json({
      error: existing.rows[0].status === 'pending'
        ? 'This order could not be cancelled. Please refresh and try again.'
        : 'Only pending orders can be cancelled.'
    });
  } catch (err) {
    console.error('cancel order error', err);
    return res.status(500).json({ error: 'Failed to cancel order' });
  }
});

// ------------------------------------------------------------
// GET /api/orders/:id — customer checks their own order status
// ------------------------------------------------------------
router.get('/:id', verifyToken, requireCustomer, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT o.*, b.name AS building_name
       FROM orders o
       JOIN buildings b ON b.id = o.building_id
       WHERE o.id = $1 AND o.customer_id = $2`,
      [req.params.id, req.user.id]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const itemsResult = await pool.query(
      `SELECT item_name, unit_price_cents, quantity, line_total_cents FROM order_items WHERE order_id = $1`,
      [req.params.id]
    );

    res.json({ order: { ...result.rows[0], items: itemsResult.rows } });
  } catch (err) {
    console.error('get order error', err);
    res.status(500).json({ error: 'Failed to fetch order' });
  }
});

// ------------------------------------------------------------
// GET /api/orders — customer's own order history
// ------------------------------------------------------------
router.get('/', verifyToken, requireCustomer, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT o.id, o.status, o.total_cents, o.created_at,
              (f.order_id IS NOT NULL) AS feedback_submitted
       FROM orders o
       LEFT JOIN order_feedback f ON f.order_id = o.id AND f.customer_id = o.customer_id
       WHERE o.customer_id = $1
       ORDER BY o.created_at DESC LIMIT 50`,
      [req.user.id]
    );
    res.json({ orders: result.rows });
  } catch (err) {
    console.error('list orders error', err);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

module.exports = router;
