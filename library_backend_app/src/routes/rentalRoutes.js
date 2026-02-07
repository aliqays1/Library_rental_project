const express = require('express');
const router = express.Router();
const { 
    createRental, 
    getMyRentals, 
    getMyHistory, 
    returnBook, 
    clearHistory,
    getAllRentals 
} = require('../controllers/rentalController');

// @route   POST /api/rentals
// @desc    Create a new rental
router.post('/rentals', createRental);

// @route   GET /api/my-rentals
// @desc    Get active rentals for a specific user/email
router.get('/my-rentals', getMyRentals);

// @route   POST /api/rentals/return
// @desc    Mark a book as returned
router.post('/rentals/return', returnBook);

// @route   GET /api/my-history
// @desc    Get returned books history
router.get('/my-history', getMyHistory);

// @route   DELETE /api/my-history/clear
// @desc    Delete all history records for a user
router.delete('/my-history/clear', clearHistory);

// @route   GET /api/admin/rentals
// @desc    Admin view for all rentals
router.get('/admin/rentals', getAllRentals);

module.exports = router;