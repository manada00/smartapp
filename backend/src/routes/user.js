const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Address = require('../models/Address');
const { protect } = require('../middleware/auth');

const router = express.Router();

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

module.exports = router;
