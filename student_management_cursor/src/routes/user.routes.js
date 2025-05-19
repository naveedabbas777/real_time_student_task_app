const express = require('express');
const multer = require('multer');
const xlsx = require('xlsx');
const { body, validationResult } = require('express-validator');
const User = require('../models/user.model');
const Task = require('../models/task.model');
const { auth, isAdmin } = require('../middleware/auth.middleware');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

// Get all students (admin only)
router.get('/students', [auth, isAdmin], async (req, res) => {
  try {
    const students = await User.find({ role: 'student' })
      .select('-password')
      .sort({ created_at: -1 });

    res.json(students);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Upload students via Excel (admin only)
router.post('/upload', [auth, isAdmin, upload.single('file')], async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Please upload an Excel file' });
    }

    const workbook = xlsx.read(req.file.buffer, { type: 'buffer' });
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(sheet);

    const results = {
      success: [],
      errors: []
    };

    for (const row of data) {
      try {
        const existingUser = await User.findOne({ email: row.email });
        if (existingUser) {
          results.errors.push({
            email: row.email,
            error: 'Email already exists'
          });
          continue;
        }

        const user = new User({
          name: row.name,
          email: row.email,
          password: row.password || Math.random().toString(36).slice(-8),
          role: 'student'
        });

        await user.save();
        results.success.push({
          name: user.name,
          email: user.email
        });
      } catch (error) {
        results.errors.push({
          email: row.email,
          error: error.message
        });
      }
    }

    res.json({
      message: 'File processed',
      results
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete student and their tasks (admin only)
router.delete('/students/:studentId', [auth, isAdmin], async (req, res) => {
  try {
    const student = await User.findOne({
      _id: req.params.studentId,
      role: 'student'
    });

    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    // Delete all tasks assigned to the student
    await Task.deleteMany({ assigned_to: student._id });
    
    // Delete the student
    await student.deleteOne();

    res.json({ message: 'Student and associated tasks deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Get student performance (admin only)
router.get('/students/:studentId/performance', [auth, isAdmin], async (req, res) => {
  try {
    const student = await User.findOne({
      _id: req.params.studentId,
      role: 'student'
    }).select('-password');

    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    const tasks = await Task.find({ assigned_to: student._id });
    
    const performance = {
      student,
      taskStats: {
        total: tasks.length,
        completed: tasks.filter(t => t.status === 'completed').length,
        pending: tasks.filter(t => t.status === 'pending').length
      },
      completionRate: tasks.length > 0 
        ? (tasks.filter(t => t.status === 'completed').length / tasks.length) * 100 
        : 0,
      recentTasks: await Task.find({ assigned_to: student._id })
        .sort({ created_at: -1 })
        .limit(5)
        .populate('created_by', 'name')
    };

    res.json(performance);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router; 