const mongoose = require('mongoose');

const rentalSchema = new mongoose.Schema({
    // Using String to match your current setup, though ObjectId is usually preferred
    bookId: {
        type: String,
        required: true
    },
    // Captured from Flutter to ensure history survives if book is deleted
    bookTitle: {
        type: String,
        required: true
    },
    author: {
        type: String
    },
    coverImage: {
        type: String
    },
    renterName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        trim: true // Removes accidental spaces
    },
    phone: {
        type: String
    },
    district: {
        type: String
    },
    rentDate: {
        type: String,
        required: true
    },
    returnDate: {
        type: String,
        required: true
    },
    // Added to track exactly when it moved to History
    actualReturnDate: {
        type: String
    },
    status: {
        type: String,
        enum: ['Active', 'Returned', 'Overdue'],
        default: 'Active',
        trim: true // Prevents "Active " (with a space) from breaking the query
    }
}, { 
    timestamps: true 
});

module.exports = mongoose.model('Rental', rentalSchema);