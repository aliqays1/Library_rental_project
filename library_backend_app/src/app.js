const express = require('express');
const cors = require('cors');
const path = require('path'); 
const session = require('express-session');
require('dotenv').config();
const connectDB = require('./config/db.js');
const mongoose = require('mongoose');

// IMPORT THE MODELS
const Rental = require('./models/Rental');
const Book = require('./models/Book');

// IMPORT ROUTES
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const adminRoutes = require('./routes/adminRoutes');

// INITIALIZE APP
connectDB();
const app = express(); // This must stay here!

// --- MIDDLEWARE ---
app.use(cors({ origin: true, credentials: true }));
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); 

app.use(session({
    secret: process.env.SESSION_SECRET || 'secret-library-key',
    resave: false,
    saveUninitialized: false, 
    cookie: { secure: false, maxAge: 1000 * 60 * 60 * 24 }
}));

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// --- RENTAL ROUTES ---

// 1. Create Rental
app.post('/api/rentals', async (req, res) => {
    try {
        const email = (req.body.email || "no-email@library.com").trim().toLowerCase();
        
        const rentalData = {
            userId: req.body.userId || null,
            bookId: req.body.bookId || null,
            bookTitle: req.body.bookTitle || "Unknown Book",
            renterName: req.body.renterName || req.body.fullname || "Guest User",
            email: email, 
            phone: req.body.phone || "No Phone",
            district: req.body.district || "No District",
            rentDate: req.body.rentDate || new Date().toISOString().split('T')[0],
            returnDate: req.body.returnDate || "No Return Date",
            status: 'Active',
            coverImage: req.body.coverImage || "",
            author: req.body.author || ""
        };

        const newRental = new Rental(rentalData);
        await newRental.save();
        
        if (rentalData.bookId && mongoose.Types.ObjectId.isValid(rentalData.bookId)) {
            await Book.findByIdAndUpdate(rentalData.bookId, { availabilityStatus: 'Out of Stock' });
        }

        res.status(201).json({ message: "Rental successful!", data: newRental });
    } catch (err) {
        res.status(500).json({ message: "Internal Server Error", error: err.message });
    }
});

// 2. Fetch Active Rentals
app.get('/api/my-rentals', async (req, res) => {
    try {
        const userEmail = req.query.email ? req.query.email.trim().toLowerCase() : null; 
        if (!userEmail) return res.status(400).json({ message: "Email required" });

        const userRentals = await Rental.find({ email: userEmail, status: 'Active' }).sort({ createdAt: -1 }); 
        res.status(200).json(userRentals);
    } catch (err) {
        res.status(500).json({ message: "Failed to fetch rentals" });
    }
});

// 3. Fetch History (The route that was missing!)
app.get('/api/my-history', async (req, res) => {
    try {
        const userEmail = req.query.email ? req.query.email.trim().toLowerCase() : null;
        if (!userEmail) return res.status(400).json({ message: "Email required" });

        const history = await Rental.find({ email: userEmail, status: 'Returned' }).sort({ actualReturnDate: -1 });
        res.status(200).json(history);
    } catch (err) {
        res.status(500).json({ message: "Failed to fetch history" });
    }
});

// 4. Return Book (Fixed to NOT delete the record)
app.post('/api/rentals/return', async (req, res) => {
    const { rentalId, bookId } = req.body;
    try {
        const updatedRental = await Rental.findByIdAndUpdate(
            rentalId, 
            { status: 'Returned', actualReturnDate: new Date().toISOString().split('T')[0] },
            { new: true }
        );

        if (!updatedRental) return res.status(404).json({ message: "Rental record not found" });

        if (bookId && mongoose.Types.ObjectId.isValid(bookId)) {
            await Book.findByIdAndUpdate(bookId, { availabilityStatus: 'Available' });
        }

        res.status(200).json({ message: "Book returned successfully!" });
    } catch (err) {
        res.status(500).json({ message: "Failed to return book", error: err.message });
    }
});

// 5. Clear History
app.delete('/api/my-history/clear', async (req, res) => {
    try {
        const userEmail = req.query.email ? req.query.email.trim().toLowerCase() : null;
        if (!userEmail) return res.status(400).json({ message: "Email required" });

        await Rental.deleteMany({ email: userEmail, status: 'Returned' });
        res.status(200).json({ message: "History cleared" });
    } catch (err) {
        res.status(500).json({ message: "Failed to clear history" });
    }
});

// --- OTHER ROUTES ---
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/admin', adminRoutes); 
app.use('/admin', adminRoutes); 

app.get('/', (req, res) => res.send("Library API Running"));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server on port ${PORT}`));