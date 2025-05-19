const express = require('express');
const { body, validationResult } = require('express-validator');
const Task = require('../models/task.model');
const { auth, isAdmin } = require('../middleware/auth.middleware');

const router = express.Router();

// Create new task (admin only)
router.post('/', [
  auth,
  isAdmin,
  body('title').trim().notEmpty(),
  body('description').trim().notEmpty(),
  body('assigned_to').notEmpty(),
  body('due_date').isISO8601().toDate()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const task = new Task({
      ...req.body,
      created_by: req.user._id
    });

    await task.save();
    await task.populate('assigned_to', 'name email');

    res.status(201).json(task);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all tasks (admin) or user's tasks (student)
router.get('/', auth, async (req, res) => {
  try {
    const query = req.user.role === 'admin' 
      ? {} 
      : { assigned_to: req.user._id };

    const tasks = await Task.find(query)
      .populate('assigned_to', 'name email')
      .populate('created_by', 'name')
      .sort({ created_at: -1 });

    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Update task status (student)
router.patch('/:taskId/status', [
  auth,
  body('status').isIn(['pending', 'completed'])
], async (req, res) => {
  try {
    const task = await Task.findOne({
      _id: req.params.taskId,
      assigned_to: req.user._id
    });

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    task.status = req.body.status;
    if (req.body.status === 'completed') {
      task.completed_at = new Date();
    }

    await task.save();
    await task.populate('assigned_to', 'name email');

    res.json(task);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete task (admin only)
router.delete('/:taskId', [auth, isAdmin], async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.taskId);
    
    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Get task statistics (admin only)
router.get('/stats', [auth, isAdmin], async (req, res) => {
  try {
    const stats = await Task.aggregate([
      {
        $group: {
          _id: '$assigned_to',
          totalTasks: { $sum: 1 },
          completedTasks: {
            $sum: {
              $cond: [{ $eq: ['$status', 'completed'] }, 1, 0]
            }
          }
        }
      },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'student'
        }
      },
      {
        $unwind: '$student'
      },
      {
        $project: {
          _id: 1,
          studentName: '$student.name',
          studentEmail: '$student.email',
          totalTasks: 1,
          completedTasks: 1,
          completionRate: {
            $multiply: [
              { $divide: ['$completedTasks', '$totalTasks'] },
              100
            ]
          }
        }
      },
      {
        $sort: { completionRate: -1 }
      }
    ]);

    res.json(stats);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router; 