const Book = require('../models/Book');

// @desc    Get all books
exports.getBooks = async (req, res, next) => {
    try {
        const books = await Book.find({});
        // If this is an API call, return JSON. If it's the dashboard, render the page.
        if (req.originalUrl.includes('/api/')) {
            return res.status(200).json(books);
        }
        res.render('dashboard', { books, activePage: 'dashboard' });
    } catch (error) {
        next(error);
    }
};

// @desc    Create a book (Handles the file upload and 0.0 rating fix)
exports.createBook = async (req, res, next) => {
    try {
        const { title, author, stockCount, rating, category, availabilityStatus } = req.body;
        
        // FIX: If req.file exists, use its path. Otherwise, use a placeholder.
        const coverImagePath = req.file ? req.file.path : 'uploads/default.jpg';

        const book = new Book({ 
            title, 
            author, 
            stockCount: parseInt(stockCount),
            category, 
            // FIX: parseFloat ensures 3.2 stays 3.2 and doesn't become 0
            rating: parseFloat(rating) || 0.0, 
            coverImage: coverImagePath, 
            availabilityStatus 
        });

        await book.save();
        res.redirect('/admin/dashboard'); 
    } catch (error) {
        next(error);
    }
};

// @desc    Update a book (Fixes the "Cannot POST" error)
exports.updateBook = async (req, res, next) => {
    try {
        const { title, author, stockCount, rating, category, availabilityStatus } = req.body;
        
        const updateData = {
            title,
            author,
            stockCount: parseInt(stockCount),
            rating: parseFloat(rating),
            category,
            availabilityStatus
        };

        // If a new image was uploaded during edit, update the path
        if (req.file) {
            updateData.coverImage = req.file.path;
        }

        const book = await Book.findByIdAndUpdate(req.params.id, updateData, { new: true });
        
        if (!book) return res.status(404).json({ message: 'Book not found' });
        res.redirect('/admin/dashboard');
    } catch (error) {
        next(error);
    }
};

// @desc    Delete a book
exports.deleteBook = async (req, res, next) => {
    try {
        await Book.findByIdAndDelete(req.params.id);
        res.redirect('/admin/dashboard');
    } catch (error) {
        next(error);
    }
};