const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true,
    trim: true
  },
  assigned_to: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  created_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'completed'],
    default: 'pending'
  },
  due_date: {
    type: Date,
    required: true
  },
  completed_at: {
    type: Date
  },
  created_at: {
    type: Date,
    default: Date.now
  }
});

// Index for better query performance
taskSchema.index({ assigned_to: 1, status: 1 });
taskSchema.index({ created_by: 1, created_at: -1 });

const Task = mongoose.model('Task', taskSchema);

module.exports = Task; 