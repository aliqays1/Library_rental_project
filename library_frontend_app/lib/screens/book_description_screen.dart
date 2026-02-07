import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rent_form_screen.dart'; 

class BookDescriptionScreen extends StatelessWidget {
  final dynamic book;

  const BookDescriptionScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // 1. Extracting data safely
    String status = book['availabilityStatus'] ?? "Available";
    double rating = double.tryParse(book['rating']?.toString() ?? '0') ?? 0.0;
    String description = book['description'] ?? "No description available for this book.";

    // Logic: Is the book rentable?
    bool isRentable = status == 'Available';

    // 2. Image Logic
    String imageUrl = "";
    if (book['coverImage'] != null) {
      String rawPath = book['coverImage'].toString();
      imageUrl = rawPath.startsWith('http') 
          ? rawPath 
          : 'http://localhost:5000/${rawPath.replaceAll('\\', '/')}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Text("Description", style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Container(
                  width: 130,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: imageUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: imageUrl.isEmpty ? const Icon(Icons.book, size: 50) : null,
                ),
                const SizedBox(width: 20),
                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text("LibraRead", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                      Text(book['title'] ?? "Title", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Author: ${book['author'] ?? 'Unknown'}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.blueAccent)),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border, 
                          color: Colors.orange, size: 20
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Icon(Icons.library_books, color: Colors.blue),
                const SizedBox(width: 10),
                Text("What the Book Is About", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),
            Text(description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.6)),
            const SizedBox(height: 25),
            
            // Status Badge: Green if Available, Red if Out of Stock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: isRentable ? Colors.green[50] : Colors.red[50], 
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                status, 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, 
                  color: isRentable ? Colors.green[700] : Colors.red[700]
                )
              ),
            ),
            const SizedBox(height: 40),
            
            // RENT BUTTON: Disables itself if not available
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isRentable ? () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RentFormScreen(book: book)),
                  );
                } : null, // Setting this to null disables the button
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRentable ? Colors.blue : Colors.grey[400],
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  isRentable ? "Rent The Book Now" : "Currently Unavailable", 
                  style: GoogleFonts.poppins(
                    color: isRentable ? Colors.white : Colors.grey[600], 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}