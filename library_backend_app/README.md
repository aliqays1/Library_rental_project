# Library Rental System 📚

A full-stack mobile application for managing library books and user rentals.

## 🚀 Project Overview
[cite_start]This project solves the real-world problem of book tracking and inventory management[cite: 8]. [cite_start]It consists of a Node.js REST API and a responsive Flutter mobile interface[cite: 12, 19].

## 🛠 Technology Stack
- [cite_start]**Backend:** Node.js, Express.js, MongoDB (Mongoose) [cite: 11, 12, 13]
- [cite_start]**Frontend:** Flutter (State management: Provider) [cite: 19, 52]
- [cite_start]**Security:** JWT Authentication & bcrypt password hashing [cite: 14, 15]

## 📂 Architecture & Features
- [cite_start]**Separate Applications:** Frontend and Backend communicate via REST APIs[cite: 22, 23].
- [cite_start]**Authentication:** Secure login/registration with JWT-protected routes[cite: 26, 27].
- [cite_start]**CRUD Operations:** Full management of Books, Users, and Rentals[cite: 30].
- **History Tracking:** Automatic tracking of returned books using Mongoose status updates.

## 📖 Setup Instructions
### Backend
1. Navigate to `/backend`
2. Run `npm install`
3. [cite_start]Create a `.env` file with `MONGO_URI` and `JWT_SECRET` 
4. Run `npm run dev`

### Frontend
1. Navigate to `/frontend`
2. Run `flutter pub get`
3. Update `baseUrl` in `book_provider.dart` to point to your server
4. Run `flutter run`

## 📊 Database Schema
[cite_start]The system uses three primary models[cite: 29]:
1. [cite_start]**User:** Manages roles (Admin/User) and credentials[cite: 28].
2. **Book:** Stores inventory details and availability status.
3. **Rental:** Tracks active and returned books (History).

## 📱 Screenshots
[cite_start][Insert your app screenshots here as required by the manual] [cite: 65]