const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const AdminUser = require('../models/AdminUser');

const router = express.Router();

async function ensureBootstrapAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  const role = process.env.ADMIN_ROLE || 'SUPER_ADMIN';

  if (!email || !password) return;

  const existing = await AdminUser.findOne({ email: email.toLowerCase() });
  if (existing) return;

  const passwordHash = await bcrypt.hash(password, 10);
  await AdminUser.create({
    email: email.toLowerCase(),
    passwordHash,
    role,
  });
}

router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 6 }).withMessage('Password is required'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, errors: errors.array() });
      }

      await ensureBootstrapAdmin();

      const { email, password } = req.body;
      console.log('[admin-login] request email:', email);
      const admin = await AdminUser.findOne({ email: email.toLowerCase() });
      console.log('Admin found:', !!admin);
      console.log('Password field exists:', !!admin?.passwordHash);
      console.log('Password received:', password);

      if (!admin || !admin.isActive) {
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
      }

      const isMatch = await bcrypt.compare(password, admin.passwordHash);
      console.log('[admin-login] password match:', isMatch);
      if (!isMatch) {
        return res.status(401).json({ success: false, message: 'Invalid credentials' });
      }

      const accessToken = jwt.sign(
        { id: admin._id.toString(), type: 'admin', role: admin.role },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' },
      );

      admin.lastLoginAt = new Date();
      await admin.save();

      return res.json({
        success: true,
        data: {
          accessToken,
          admin: {
            id: admin._id,
            email: admin.email,
            role: admin.role,
          },
        },
      });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  },
);

module.exports = router;
