const express = require('express');
const { pool } = require('../config/db');

const router = express.Router();

// Public catalogue used by the menu and checkout to resolve trusted database IDs.
router.get('/', async (_req, res) => {
  try {
    const [menuResult, buildingResult] = await Promise.all([
      pool.query('SELECT id, name, price_cents FROM menu_items WHERE is_available = TRUE ORDER BY name'),
      pool.query('SELECT id, name FROM buildings WHERE is_active = TRUE ORDER BY name')
    ]);
    res.json({ menuItems: menuResult.rows, buildings: buildingResult.rows });
  } catch (err) {
    console.error('catalogue error', err);
    res.status(500).json({ error: 'Could not load the menu and delivery locations' });
  }
});

module.exports = router;
