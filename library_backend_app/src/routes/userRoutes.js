const express = require('express');
const router = express.Router();
const Book = require('../models/Book');
const userController = require('../controllers/userController'); // Import the controller
const { protect } = require('../middleware/authMiddleware');    // Import the middleware

// @desc Get all books for Flutter app
router.get('/all-books', async (req, res) => {
    try {
        const books = await Book.find();
        res.json(books);
    } catch (err) {
        res.status(500).json({ message: "Error fetching books" });
    }
});

// --- NEWLY ADDED DELETE ROUTE ---
// This route is protected, meaning a valid Bearer token is required
// URL: /api/users/delete
router.delete('/delete', protect, userController.deleteUser);

module.exports = router;