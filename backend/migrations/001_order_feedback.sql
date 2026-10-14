-- Run this migration ONLY against the Campus Eats TEST Neon branch.
-- Adds one feedback record per delivered order.
CREATE TABLE IF NOT EXISTS order_feedback (
  order_id UUID PRIMARY KEY REFERENCES orders(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment VARCHAR(1000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_order_feedback_customer ON order_feedback(customer_id);
