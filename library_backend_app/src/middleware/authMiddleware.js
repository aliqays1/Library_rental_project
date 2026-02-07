const jwt = require('jsonwebtoken');
const User = require('../models/User');

// --- FOR FLUTTER/API ---
// Checks for JWT Token in headers
const protect = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = await User.findById(decoded.id).select('-password');
            
            if (!req.user) {
                return res.status(401).json({ message: 'User not found' });
            }

            return next(); 
        } catch (error) {
            console.error("Token Validation Error:", error.message);
            return res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }

    if (!token) {
        return res.status(401).json({ message: 'Not authorized, no token' });
    }
};

// --- FOR BROWSER ADMIN PANEL ---
// Use this on your /admin/dashboard route to stop direct URL access
const protectAdmin = (req, res, next) => {
    // Check if the user is saved in the session (logged in via browser)
    if (req.session && req.session.user && req.session.user.role === 'admin') {
        return next(); // They are an admin, let them in!
    } else {
        // Not logged in or not an admin, kick them back to login page
        console.log("Unauthorized dashboard access attempt.");
        return res.redirect('/admin/login'); 
    }
};

// Original admin middleware (for API roles)
const admin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        res.status(403).json({ message: 'Not authorized as an admin' });
    }
};

module.exports = { protect, admin, protectAdmin };