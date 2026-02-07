const User = require('../models/User');
const Rental = require('../models/Rental');
const Book = require('../models/Book');

// @desc    Get user profile & personal stats
// @route   GET /api/users/profile
exports.getUserProfile = async (req, res, next) => {
    try {
        const user = await User.findById(req.user._id).select('-password');
        
        // Count books currently rented by this specific user
        const rentedCount = await Rental.countDocuments({
            userId: req.user._id,
            status: 'active'
        });

        // Count total books in the library for the "Available" stat
        const totalAvailable = await Book.countDocuments({ availability: true });

        res.json({
            user,
            stats: {
                booksRented: rentedCount,
                availableInLibrary: totalAvailable,
                totalRentalsEver: await Rental.countDocuments({ userId: req.user._id })
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get Admin Dashboard Stats (Admin Only)
// @route   GET /api/users/admin/stats
exports.getAdminStats = async (req, res, next) => {
    try {
        const totalUsers = await User.countDocuments({ role: 'user' });
        const totalBooks = await Book.countDocuments();
        const activeRentals = await Rental.countDocuments({ status: 'active' });

        res.json({
            totalUsers,
            totalBooks,
            activeRentals
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Add/Remove book from favorites
// @route   POST /api/users/favorite/:bookId
exports.toggleFavorite = async (req, res, next) => {
    try {
        const user = await User.findById(req.user._id);
        const bookId = req.params.bookId;

        const isFavorite = user.favorites.includes(bookId);

        if (isFavorite) {
            user.favorites.pull(bookId);
        } else {
            user.favorites.push(bookId);
        }

        await user.save();
        res.json({
            success: true,
            message: isFavorite ? "Removed from favorites" : "Added to favorites",
            favorites: user.favorites
        });
    } catch (error) {
        next(error);
    }
};

// --- NEWLY ADDED DELETE LOGIC ---
// @desc    Delete user account
// @route   DELETE /api/users/delete
exports.deleteUser = async (req, res, next) => {
    try {
        const user = await User.findById(req.user._id);

        if (user) {
            // Delete the user from the database
            await User.findByIdAndDelete(req.user._id);
            
            // Note: You may want to delete the user's rentals as well:
            // await Rental.deleteMany({ userId: req.user._id });

            res.status(200).json({ 
                success: true, 
                message: 'Account deleted successfully' 
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        next(error);
    }
};