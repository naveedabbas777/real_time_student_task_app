# Student Task Tracker App

A real-time student task management system built with Node.js, Express, MongoDB Atlas, and Flutter.

## Features

### Admin (Teacher) Features
- Upload students via Excel file or add manually
- Assign tasks to individual students
- View and export task completion reports
- Track student performance with graphs
- Delete students and their associated tasks
- View top-performing students

### Student Features
- Login with provided credentials
- View assigned tasks
- Mark tasks as completed
- View personal progress graph

## Backend Setup

### Prerequisites
- Node.js (v14 or higher)
- MongoDB Atlas account
- npm or yarn package manager

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd student-task-tracker
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory with the following variables:
```
PORT=5000
MONGODB_URI=your_mongodb_atlas_connection_string
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d
```

4. Start the development server:
```bash
npm run dev
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login for both admin and students
- `POST /api/auth/register` - Register new student (admin only)
- `GET /api/auth/profile` - Get current user profile

### User Management
- `GET /api/users/students` - Get all students (admin only)
- `POST /api/users/upload` - Upload students via Excel file (admin only)
- `DELETE /api/users/students/:studentId` - Delete student and their tasks (admin only)
- `GET /api/users/students/:studentId/performance` - Get student performance (admin only)

### Task Management
- `POST /api/tasks` - Create new task (admin only)
- `GET /api/tasks` - Get all tasks (admin) or user's tasks (student)
- `PATCH /api/tasks/:taskId/status` - Update task status (student)
- `DELETE /api/tasks/:taskId` - Delete task (admin only)
- `GET /api/tasks/stats` - Get task statistics (admin only)

## Excel Upload Format

The Excel file for uploading students should have the following columns:
- `name` - Student's full name
- `email` - Student's email address
- `password` (optional) - If not provided, a random password will be generated

## Authentication

The API uses JWT (JSON Web Token) for authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Error Handling

The API returns appropriate HTTP status codes and error messages:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error

## Development

### Code Structure
```
src/
  ├── models/         # Database models
  ├── routes/         # API routes
  ├── middleware/     # Custom middleware
  └── server.js       # Main application file
```

### Adding New Features
1. Create new models in `src/models/`
2. Add routes in `src/routes/`
3. Update documentation

## License

MIT License 