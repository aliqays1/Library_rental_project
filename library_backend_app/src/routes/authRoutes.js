const express = require('express');
const router = express.Router();
const { registerUser, loginUser, updateEmail, updatePassword } = require('../controllers/authController');

// Standard API routes
router.post('/register', registerUser);
router.post('/login', loginUser);

// NEW: Routes for account settings
// Note: These should ideally use a middleware to verify the JWT token
router.put('/update-email', updateEmail); 
router.put('/update-password', updatePassword);

module.exports = router;