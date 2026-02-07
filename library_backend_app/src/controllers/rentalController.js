const Rental = require('../models/Rental');
const Book = require('../models/Book');

// @desc    Rent a book
// @route   POST /api/rentals
exports.createRental = async (req, res, next) => {
    try {
        const { bookId, returnDate, renterName, email, phone, district, coverImage, author, bookTitle } = req.body;

        const book = await Book.findById(bookId);
        if (!book) return res.status(404).json({ message: 'Book not found' });
        
        if (!book.availability) return res.status(400).json({ message: 'Book is already rented' });

        const rental = new Rental({
            userId: req.user ? req.user._id : null, 
            bookId,
            bookTitle: bookTitle || book.title,
            renterName,
            // Normalizing email to lowercase on creation to prevent future mismatches
            email: (email || req.user.email).trim().toLowerCase(), 
            phone,
            district,
            rentDate: new Date().toISOString().split('T')[0], 
            returnDate,
            coverImage,
            author,
            status: 'Active' 
        });

        const createdRental = await rental.save();

        book.availability = false;
        await book.save();

        res.status(201).json(createdRental);
    } catch (error) {
        next(error);
    }
};

// @desc    Get logged in user ACTIVE rentals (My Rentals)
// @route   GET /api/my-rentals
exports.getMyRentals = async (req, res, next) => {
    try {
        const email = req.query.email ? req.query.email.trim() : null;
        
        const query = { status: 'Active' };
        if (email) {
            // Case-insensitive regex search for My Rentals
            query.$or = [
                { userId: req.user ? req.user._id : null }, 
                { email: { $regex: new RegExp(`^${email}$`, 'i') } }
            ];
        } else {
            query.userId = req.user ? req.user._id : null;
        }

        const rentals = await Rental.find(query).populate('bookId');
        res.status(200).json(rentals);
    } catch (error) {
        next(error);
    }
};

// @desc    Get logged in user RETURNED history (Rental History)
// @route   GET /api/my-history
exports.getMyHistory = async (req, res, next) => {
    try {
        const email = req.query.email ? req.query.email.trim() : null;

        let query = { status: 'Returned' };
        
        if (email) {
            // CASE-INSENSITIVE REGEX: Matches email regardless of uppercase/lowercase
            query.$or = [
                { email: { $regex: new RegExp(`^${email}$`, 'i') } },
                { userId: req.user ? req.user._id : null }
            ];
        } else if (req.user) {
            query.userId = req.user._id;
        }

        const history = await Rental.find(query).sort({ actualReturnDate: -1, createdAt: -1 });
        
        // Debugging log for your terminal
        console.log(`[History] Email: ${email} | Found: ${history.length} records`);
        
        res.status(200).json(history);
    } catch (error) {
        next(error);
    }
};

// @desc    Update rental status to 'Returned'
// @route   POST /api/rentals/return
exports.returnBook = async (req, res, next) => {
    try {
        const { rentalId, bookId } = req.body;

        const rental = await Rental.findById(rentalId);
        if (!rental) return res.status(404).json({ message: 'Rental record not found' });

        rental.status = 'Returned'; 
        rental.actualReturnDate = new Date().toISOString().split('T')[0];
        await rental.save();

        await Book.findByIdAndUpdate(bookId, { availability: true });

        res.status(200).json({ message: 'Book returned successfully' });
    } catch (error) {
        next(error);
    }
};

// @desc    Clear History
exports.clearHistory = async (req, res, next) => {
    try {
        const email = req.query.email ? req.query.email.trim() : null;
        const query = { status: 'Returned' };
        
        if (email) {
            query.$or = [
                { userId: req.user ? req.user._id : null }, 
                { email: { $regex: new RegExp(`^${email}$`, 'i') } }
            ];
        }

        await Rental.deleteMany(query);
        res.status(200).json({ message: 'Rental history cleared successfully' });
    } catch (error) {
        next(error);
    }
};

// @desc    Get all rentals (Admin Only)
exports.getAllRentals = async (req, res, next) => {
    try {
        const rentals = await Rental.find({}).populate('userId', 'username').populate('bookId', 'title');
        res.status(200).json(rentals);
    } catch (error) {
        next(error);
    }
};