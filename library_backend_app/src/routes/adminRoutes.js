const express = require('express');
const router = express.Router();
const Book = require('../models/Book');
const multer = require('multer');
const adminController = require('../controllers/adminController');
const authController = require('../controllers/authController');
const { protectAdmin } = require('../middleware/authMiddleware');

const Rental = require('../models/Rental'); 

// Configure Multer for images
const storage = multer.diskStorage({
  destination: 'uploads/',
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage });

// --- BROWSER VIEW ROUTES ---
router.get('/login', (req, res) => {
    res.render('login', { error: null });
});

router.get('/dashboard', protectAdmin, async (req, res) => {
  try {
    const allBooks = await Book.find();
    res.render('dashboard', { books: allBooks, activePage: 'dashboard' });
  } catch (err) {
    res.status(500).send("Error loading books");
  }
});

// --- UPDATED DATA ROUTE FOR FLUTTER ---
router.get('/dashboard-data', async (req, res) => {
  try {
    const allBooks = await Book.find();
    res.setHeader('Content-Type', 'application/json');
    res.status(200).json(allBooks); 
  } catch (err) {
    res.status(500).json({ message: "Error loading books for app" });
  }
});

// --- UPDATED RENTAL ROUTE ---
router.get('/rentals', protectAdmin, async (req, res) => {
  try {
    const activeRentals = await Rental.find().sort({ createdAt: -1 }); 
    res.render('rentals', { rentals: activeRentals, activePage: 'rentals' });
  } catch (err) {
    console.error("Error fetching rentals for Admin:", err);
    res.status(500).send("Error loading rentals page");
  }
});

// --- PROTECTED ROUTES ---
router.get('/users', protectAdmin, adminController.getUserList);

// Updated to ensure the book object (including description) is passed to the edit page
router.get('/edit-book/:id', protectAdmin, async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) return res.status(404).send("Book not found");
    res.render('edit-book', { book }); // description will now be available here
  } catch (err) {
    res.status(500).send("Error loading edit page");
  }
});

// --- API ACTIONS ---
router.post('/register', authController.registerUser);

// Ensure adminController.addBook captures req.body.description
router.post('/add-book', protectAdmin, upload.single('coverImage'), adminController.addBook);

// Ensure adminController.updateBook updates req.body.description
router.post('/update-book/:id', protectAdmin, upload.single('coverImage'), adminController.updateBook);

router.get('/delete-book/:id', protectAdmin, adminController.deleteBook);
router.get('/delete-user/:id', protectAdmin, adminController.deleteUser);

module.exports = router;