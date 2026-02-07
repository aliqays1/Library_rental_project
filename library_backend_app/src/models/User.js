const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    username: { 
        type: String, 
        required: [true, 'Username is required'], 
        unique: true,
        trim: true 
    },
    email: { 
        type: String, 
        required: [true, 'username is required'], 
        unique: true, 
        lowercase: true,
        trim: true 
    },
    password: { 
        type: String, 
        required: [true, 'Password is required'] 
    },
    mobile: { 
        type: String,
        default: "" 
    },
    role: { 
        type: String, 
        enum: ['user', 'admin'], 
        default: 'user' 
    },
    favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Book' }]
}, { 
    timestamps: true,
    collection: 'users'
});

// FIXED: Removed 'next' to prevent "next is not a function" crash
// In modern Mongoose, async functions handle the flow automatically
userSchema.pre('save', async function() {
    if (!this.isModified('password')) return;
    
    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
    } catch (err) {
        throw err; // This sends the error up to your Controller's catch block
    }
});

userSchema.methods.comparePassword = async function(enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);