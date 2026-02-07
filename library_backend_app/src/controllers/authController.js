const User = require('../models/User');
const jwt = require('jsonwebtoken');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

exports.registerUser = async (req, res) => {
    try {
        const { username, email, password } = req.body;
        await User.syncIndexes();
        const userExists = await User.findOne({ email });
        if (userExists) return res.status(400).json({ message: "User already exists" });
        const user = new User({ username, email, password, role: 'user' });
        const savedUser = await user.save();
        res.status(201).json({
            _id: savedUser._id,
            username: savedUser.username,
            email: savedUser.email,
            role: savedUser.role,
            token: generateToken(savedUser._id)
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.loginUser = async (req, res) => {
    try {
        const { username, password } = req.body;
        const user = await User.findOne({ username });
        const isWeb = req.headers['content-type']?.includes('application/x-www-form-urlencoded');
        if (!user || !(await user.comparePassword(password))) {
            if (isWeb) return res.render('login', { error: "Invalid credentials" });
            return res.status(401).json({ message: "Invalid credentials" });
        }
        if (isWeb) {
            if (user.role !== 'admin') return res.render('login', { error: "access denied! Admin Only" });
            req.session.user = { id: user._id, username: user.username, role: user.role };
            return req.session.save(() => res.redirect('/admin/dashboard'));
        }
        res.json({
            _id: user._id,
            token: generateToken(user._id),
            username: user.username,
            email: user.email,
            role: user.role
        });
    } catch (error) {
        res.status(500).json({ message: "Server Error" });
    }
};

exports.updateEmail = async (req, res) => {
    try {
        const token = req.headers.authorization.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ message: "User not found" });
        user.email = req.body.email.toLowerCase();
        await user.save();
        res.status(200).json({ message: "Email updated successfully", email: user.email });
    } catch (error) {
        res.status(500).json({ message: "Failed to update email" });
    }
};

exports.updatePassword = async (req, res) => {
    try {
        const token = req.headers.authorization.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id);
        if (!user || !(await user.comparePassword(req.body.oldPassword))) {
            return res.status(401).json({ message: "Old password incorrect" });
        }
        user.password = req.body.newPassword;
        await user.save();
        res.status(200).json({ message: "Password updated successfully" });
    } catch (error) {
        res.status(500).json({ message: "Failed to update password" });
    }
};