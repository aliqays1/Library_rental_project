const Book = require('../models/Book');
const User = require('../models/User');

// 1. Get User List
exports.getUserList = async (req, res) => {
    try {
        const users = await User.find();
        res.render('user-list', { users, activePage: 'users' });
    } catch (err) {
        res.status(500).send("Error fetching users");
    }
};

// 2. Get Rental List
exports.getRentalList = async (req, res) => {
    try {
        const rentals = [];
        res.render('rentals', { rentals, activePage: 'rentals' });
    } catch (err) {
        res.status(500).send("Error fetching rentals");
    }
};

// 3. Add New Book 
exports.addBook = async (req, res) => {
    try {
        // Destructure 'description' from req.body
        const { title, author, stockCount, rating, category, availabilityStatus, description } = req.body;
        
        const newBook = new Book({
            title,
            author,
            description, // SAVE THE DESCRIPTION HERE
            stock: parseInt(stockCount) || 0,
            category,
            rating: parseFloat(rating) || 0,
            coverImage: req.file ? req.file.path : 'uploads/default.jpg',
            availabilityStatus
        });

        await newBook.save();
        res.redirect('/admin/dashboard');
    } catch (err) {
        console.error("Add Book Error:", err);
        res.status(500).send("Error adding book");
    }
};

// 4. Update Existing Book 
exports.updateBook = async (req, res) => {
    try {
        const { title, author, stockCount, rating, category, availabilityStatus, description } = req.body;
        
        const updateData = {
            title,
            author,
            description, // UPDATE THE DESCRIPTION HERE
            stock: parseInt(stockCount) || 0,
            rating: parseFloat(rating) || 0,
            category,
            availabilityStatus
        };

        if (req.file) {
            updateData.coverImage = req.file.path;
        }

        await Book.findByIdAndUpdate(req.params.id, updateData);
        res.redirect('/admin/dashboard');
    } catch (err) {
        console.error("Update Book Error:", err);
        res.status(500).send("Error updating book");
    }
};

// 5. Delete Book
exports.deleteBook = async (req, res) => {
    try {
        await Book.findByIdAndDelete(req.params.id);
        res.redirect('/admin/dashboard');
    } catch (err) {
        res.status(500).send("Error deleting book");
    }
};

// 6. Delete User
exports.deleteUser = async (req, res) => {
    try {
        await User.findByIdAndDelete(req.params.id);
        res.redirect('/admin/users');
    } catch (err) {
        res.status(500).send("Error deleting user");
    }
};