const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
    title: { type: String, required: true },
    author: { type: String, required: true },
    
    // Updated description to have a default value so Flutter doesn't show "null"
    description: { 
        type: String, 
        default: "No description available for this book." 
    },
    
    category: { type: String, required: true }, 
    rating: { type: Number, default: 0 },
    stock: { type: Number, default: 1 },
    availableUnits: { type: Number, default: 1 },
    
    // Matches your Admin Panel status options
    availabilityStatus: { 
        type: String, 
        enum: ['Available', 'Out of Stock', 'Coming Soon'],
        default: 'Available' 
    },

    // Kept for Flutter logic
    availability: { 
        type: Boolean, 
        default: true,
        get: function() { 
            // A book is only truly available if status is 'Available' and units > 0
            return this.availabilityStatus === 'Available' && this.availableUnits > 0; 
        } 
    },
    
    coverImage: { type: String }, 
    publishDate: { type: String }
}, { 
    timestamps: true,
    toJSON: { getters: true },
    toObject: { getters: true }
});

module.exports = mongoose.model('Book', bookSchema);