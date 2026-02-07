const jwt = require('jsonwebtoken');
const User = require('../models/User');

const isAdmin = async (req, res, next) => {
    try {
        // 1. Get token from header
        const token = req.headers.authorization?.split(" ")[1];
        if (!token) return res.status(401).json({ message: "No token, authorization denied" });

        // 2. Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id);

        // 3. Check if user is Admin
        if (user && user.role === 'admin') {
            req.user = user;
            next();
        } else {
            res.status(403).json({ message: "Access denied: Admins only" });
        }
    } catch (error) {
        res.status(401).json({ message: "Token is not valid" });
    }
};

module.exports = { isAdmin };