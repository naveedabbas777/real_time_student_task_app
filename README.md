# Real-time Student Task App

A full-stack application for managing student tasks in real-time using Flutter, Node.js, and MongoDB Atlas.

## Features

### Admin (Teacher) Features
- Student Management
  - Excel import
  - Manual addition/editing
  - Student deletion
- Task Management
  - Assign tasks to specific students
  - Track task completion
- Reporting
  - View student-wise task reports
  - Export reports
  - Performance graphs

### Student Features
- View assigned tasks
- Mark tasks as complete
- Track progress with performance metrics
- Real-time task updates

## Tech Stack

### Backend
- Node.js + Express
- MongoDB Atlas
- JWT Authentication
- Excel file parsing with `xlsx`

### Frontend (Mobile)
- Flutter
- Provider for state management
- fl_chart for data visualization
- HTTP for API communication
- Secure storage for token management

## Project Structure

```
.
├── backend/
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── index.js
│   ├── package.json
│   └── .env.example
└── mobile/
    ├── lib/
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   ├── services/
    │   ├── widgets/
    │   └── main.dart
    └── pubspec.yaml
```

## Getting Started

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file based on `.env.example` and update the values:
   ```
   PORT=3000
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

### Mobile App Setup

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update the API base URL in `lib/services/api_service.dart` if needed.

4. Run the app:
   ```bash
   flutter run
   ```

## Environment Variables

### Backend
- `PORT`: Server port (default: 3000)
- `MONGODB_URI`: MongoDB Atlas connection string
- `JWT_SECRET`: Secret key for JWT token generation

## API Endpoints

### Authentication
- `POST /api/auth/login`: User login

### Tasks
- `GET /api/tasks/my-tasks`: Get student's tasks
- `GET /api/tasks/admin`: Get all tasks (admin only)
- `POST /api/tasks`: Create task (admin only)
- `PATCH /api/tasks/:id/status`: Update task status

### Users
- `GET /api/users/students`: Get all students (admin only)
- `POST /api/users/students`: Create student (admin only)
- `POST /api/users/students/import`: Import students from Excel (admin only)

### Reports
- `GET /api/reports/student/:id`: Get student performance report
- `GET /api/reports/top-performers`: Get top performing students

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
