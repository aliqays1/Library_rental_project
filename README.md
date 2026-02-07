# Library Rental Management System 📚

A professional full-stack application designed to manage book rentals, tracking, and user history. This project solves real-world inventory problems using a secure backend and a responsive mobile interface.

## 🚀 Project Overview
This system allows users to browse available books, rent them, and view their rental history. It features role-based access for Admins and regular Users.

## 📥 Download Live Application
You can download and test the mobile application (APK) from the link below:
- **[Download APK (Google Drive)](https://drive.google.com/file/d/1We-L9hpXjU-tMuwqFHfCXYHw5I-uv_mF/view?usp=sharing)**

## 🛠 Technology Stack
### Backend (Node.js)
- [cite_start]**Framework:** Express.js for REST APIs [cite: 12]
- [cite_start]**Database:** MongoDB with Mongoose [cite: 13]
- [cite_start]**Security:** JWT Authentication & bcrypt Password Hashing [cite: 14, 15]
- [cite_start]**Architecture:** Separation of routes, controllers, and models [cite: 17]

### Frontend (Flutter)
- [cite_start]**State Management:** Provider pattern [cite: 52]
- [cite_start]**Navigation:** Bottom Navigation Bar & Drawer [cite: 51]
- [cite_start]**Networking:** REST API consumption via JSON [cite: 20]
- [cite_start]**Design:** Responsive UI for Android and iOS [cite: 47, 54]

## 🏗 System Architecture
[cite_start]The system follows a decoupled architecture where the Frontend and Backend are separate applications[cite: 22]. [cite_start]Communication is handled via RESTful APIs[cite: 23].

**Diagram Flow:**
`Flutter App (UI) <--> REST API (Express) <--> Database (MongoDB)`

## 📊 Database Schema
[cite_start]The system utilizes three main database models[cite: 29]:
1. **User Model:** Stores credentials, hashed passwords, and roles (Admin/User).
2. **Book Model:** Stores book details (Title, Author, Availability, Images).
3. **Rental Model:** Tracks rental transactions, including status (Active/Returned).

## 🔌 API Documentation
[cite_start]The backend exposes the following key endpoints:
- [cite_start]`POST /api/auth/register` - User registration [cite: 26]
- [cite_start]`POST /api/auth/login` - User login & JWT issuance [cite: 26, 27]
- [cite_start]`GET /api/books` - Fetch all available books [cite: 30]
- [cite_start]`POST /api/rentals` - Create a new rental record (Protected) [cite: 27]
- [cite_start]`GET /api/my-history` - Fetch rental history for the logged-in user [cite: 30]

## 📱 Features & Screenshots
- [cite_start]**User Authentication:** Secure login and registration[cite: 26].
- [cite_start]**Book Management:** Full CRUD operations for library inventory[cite: 30].
- **History Tracking:** Users can view their past and current rentals.
- [cite_start]**Responsive Design:** Consistent UI across different screen sizes[cite: 54, 55].

## ⚙️ Setup & Installation
### Backend Setup
1. Navigate to `/library_backend_app`
2. Run `npm install`
3. [cite_start]Configure `.env` with `MONGO_URI` and `JWT_SECRET` [cite: 16]
4. Start server: `npm run dev`

### Frontend Setup
1. Navigate to `/library_frontend_app`
2. Run `flutter pub get`
3. Update `baseUrl` in `api_service.dart` to your server IP
4. Run `flutter run`

## 📄 License & Integrity
[cite_start]This project was developed as a Final Year Project for the Department of Computer Science[cite: 2]. [cite_start]All code is original and adheres to academic integrity standards[cite: 36].