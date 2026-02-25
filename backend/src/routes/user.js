const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Address = require('../models/Address');
const AppConfig = require('../models/AppConfig');
const SupportTicket = require('../models/SupportTicket');
const { protect } = require('../middleware/auth');

const router = express.Router();

const getOrCreateAppConfig = async () => {
  let config = await AppConfig.findOne({ key: 'default' });
  if (!config) {
    config = await AppConfig.create({
      key: 'default',
      supportContact: {
        phone: '01552785430',
        email: 'support@smartfood.app',
        whatsapp: '01552785430',
      },
    });
  }
  return config;
};

// Get profile
router.get('/profile', protect, async (req, res) => {
  try {
    res.json({
      success: true,
      data: req.user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Update profile
router.put('/profile', protect, async (req, res) => {
  try {
    const { name, email, dateOfBirth, gender, profileImage } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { name, email, dateOfBirth, gender, profileImage },
      { new: true }
    );

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Update health goals
router.put('/health-goals', protect, async (req, res) => {
  try {
    const { healthGoals } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { healthGoals },
      { new: true }
    );

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Update dietary preferences
router.put('/dietary-preferences', protect, async (req, res) => {
  try {
    const { dietaryPreferences } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { dietaryPreferences },
      { new: true }
    );

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Update daily routine
router.put('/daily-routine', protect, async (req, res) => {
  try {
    const { dailyRoutine } = req.body;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { dailyRoutine },
      { new: true }
    );

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Complete onboarding
router.put('/complete-onboarding', protect, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { isOnboardingComplete: true },
      { new: true }
    );

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get addresses
router.get('/addresses', protect, async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user._id });

    res.json({
      success: true,
      data: addresses,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Add address
router.post('/addresses', protect, async (req, res) => {
  try {
    const address = await Address.create({
      ...req.body,
      user: req.user._id,
    });

    // If this is the first address or marked as default
    if (req.body.isDefault) {
      await Address.updateMany(
        { user: req.user._id, _id: { $ne: address._id } },
        { isDefault: false }
      );
    }

    res.status(201).json({
      success: true,
      data: address,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Update address
router.put('/addresses/:id', protect, async (req, res) => {
  try {
    const address = await Address.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      req.body,
      { new: true }
    );

    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    if (req.body.isDefault) {
      await Address.updateMany(
        { user: req.user._id, _id: { $ne: address._id } },
        { isDefault: false }
      );
    }

    res.json({
      success: true,
      data: address,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Delete address
router.delete('/addresses/:id', protect, async (req, res) => {
  try {
    const address = await Address.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    res.json({
      success: true,
      message: 'Address deleted',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get support config
router.get('/support/config', protect, async (req, res) => {
  try {
    const config = await getOrCreateAppConfig();
    return res.json({
      success: true,
      data: {
        phone: config.supportContact?.phone || '01552785430',
        email: config.supportContact?.email || 'support@smartfood.app',
        whatsapp: config.supportContact?.whatsapp || config.supportContact?.phone || '01552785430',
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Get current user support tickets
router.get('/support/tickets', protect, async (req, res) => {
  try {
    const tickets = await SupportTicket.find({ user: req.user._id })
      .sort({ updatedAt: -1 })
      .limit(100)
      .select('subject status priority initialChannel messages createdAt updatedAt');

    return res.json({ success: true, data: tickets });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Create support ticket
router.post('/support/tickets', protect, async (req, res) => {
  try {
    const { subject, message, channel = 'message', priority = 'medium' } = req.body;

    const trimmedSubject = String(subject || '').trim();
    const trimmedMessage = String(message || '').trim();
    if (!trimmedSubject || !trimmedMessage) {
      return res.status(400).json({ success: false, message: 'subject and message are required' });
    }

    const ticket = await SupportTicket.create({
      user: req.user._id,
      subject: trimmedSubject,
      priority: ['low', 'medium', 'high'].includes(String(priority)) ? String(priority) : 'medium',
      initialChannel: ['message', 'email'].includes(String(channel)) ? String(channel) : 'message',
      messages: [{
        senderType: 'user',
        senderUser: req.user._id,
        channel: ['message', 'email'].includes(String(channel)) ? String(channel) : 'message',
        content: trimmedMessage,
        createdAt: new Date(),
      }],
    });

    return res.status(201).json({ success: true, data: ticket });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Reply to support ticket
router.post('/support/tickets/:id/reply', protect, async (req, res) => {
  try {
    const { message, channel = 'message' } = req.body;
    const trimmedMessage = String(message || '').trim();
    if (!trimmedMessage) {
      return res.status(400).json({ success: false, message: 'message is required' });
    }

    const ticket = await SupportTicket.findOne({ _id: req.params.id, user: req.user._id });
    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found' });
    }

    ticket.messages.push({
      senderType: 'user',
      senderUser: req.user._id,
      channel: ['message', 'email'].includes(String(channel)) ? String(channel) : 'message',
      content: trimmedMessage,
      createdAt: new Date(),
    });

    if (ticket.status === 'resolved' || ticket.status === 'closed') {
      ticket.status = 'open';
    }

    await ticket.save();

    return res.json({ success: true, data: ticket });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
