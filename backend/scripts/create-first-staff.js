```javascript
require('dotenv').config();
const bcrypt = require('bcrypt');
const { pool } = require('../config/db');

async function createFirstStaff() {
  const { STAFF_NAME, STAFF_EMAIL, STAFF_PHONE, STAFF_PASSWORD } = process.env;

  if (!STAFF_NAME || !STAFF_EMAIL || !STAFF_PHONE || !STAFF_PASSWORD) {
    throw new Error(
      'Set STAFF_NAME, STAFF_EMAIL, STAFF_PHONE and STAFF_PASSWORD first.'
    );
  }

  if (STAFF_PASSWORD.length < 12) {
    throw new Error('Use a password with at least 12 characters.');
  }

  const existing = await pool.query(
    'SELECT COUNT(*)::int AS count FROM staff'
  );

  if (existing.rows[0].count > 0) {
    throw new Error(
      'Staff already exists. This setup script only works on an empty staff table.'
    );
  }

  const passwordHash = await bcrypt.hash(STAFF_PASSWORD, 12);

  const result = await pool.query(
    `INSERT INTO staff (full_name, email, phone, password_hash, role)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, full_name, email, role`,
    [
      STAFF_NAME,
      STAFF_EMAIL.toLowerCase(),
      STAFF_PHONE,
      passwordHash,
      'admin'
    ]
  );

  console.log('First staff account created:', result.rows[0]);
}

createFirstStaff()
  .catch((error) => {
    console.error('Setup failed:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });
```
