import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'main_navigation.dart';

class MyRentalScreen extends StatefulWidget {
  const MyRentalScreen({super.key});

  @override
  State<MyRentalScreen> createState() => _MyRentalScreenState();
}

class _MyRentalScreenState extends State<MyRentalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).fetchRentals();
    });
  }

  String _getRemainingTime(String? returnDateStr) {
    if (returnDateStr == null || returnDateStr == "mm-dd-yy" || returnDateStr == "Pending") {
      return "Time unknown";
    }
    
    try {
      DateTime dueDate = DateTime.parse(returnDateStr);
      DateTime now = DateTime.now();
      int daysLeft = dueDate.difference(now).inDays;

      if (daysLeft < 0) return "Overdue!";
      if (daysLeft == 0) return "Due today!";
      return "$daysLeft days remaining";
    } catch (e) {
      return "Rental active"; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    
    // This now uses the ID-based filtering logic from your updated Provider
    final rentals = bookProvider.activeRentals;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            navKey.currentState?.setTab(0);
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Text("My Rental",
              style: GoogleFonts.poppins(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You have ${rentals.length} books rented",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 20),
            Expanded(
              child: bookProvider.isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : rentals.isEmpty
                  ? Center(
                      child: Text(
                        "No active rentals found.",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: rentals.length,
                      itemBuilder: (context, index) {
                        final rental = rentals[index];
                        return _buildRentalCard(context, rental, bookProvider);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalCard(
      BuildContext context, dynamic rental, BookProvider provider) {
    
    final String rawPath = rental['bookImage'] ?? rental['image'] ?? rental['coverImage'] ?? '';
    final String baseUrl = provider.baseUrl;

    String finalImageUrl = "";
    if (rawPath.isNotEmpty) {
      if (rawPath.startsWith('http')) {
        finalImageUrl = rawPath;
      } else {
        finalImageUrl = "$baseUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath";
      }
    }

    final String authorName = rental['bookAuthor'] ?? rental['author'] ?? "Unknown Author";

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: finalImageUrl.isNotEmpty
                ? Image.network(
                    finalImageUrl,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rental['bookTitle'] ?? "No Title",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(authorName,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey)),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.black),
                    const SizedBox(width: 5),
                    Text("${rental['rentDate'] ?? 'N/A'}",
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.red[300])),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_month, size: 12, color: Colors.black),
                    const SizedBox(width: 5),
                    Text("${rental['returnDate'] ?? 'Pending'}",
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.red[300])),
                  ],
                ),
                const SizedBox(height: 5),
                Text(_getRemainingTime(rental['returnDate']),
                    style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // This triggers the move to History in the Provider
              bool success = await provider.returnBook(rental['_id'], rental['bookId']);
              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Book Returned Successfully!"), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF00),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text("Return",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.book, color: Colors.grey),
    );
  }
}