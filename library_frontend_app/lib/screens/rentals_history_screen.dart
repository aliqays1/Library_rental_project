import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class RentalsHistoryScreen extends StatelessWidget {
  const RentalsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final history = bookProvider.pastRentals;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Rentals History",
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: () {
                    _showClearDialog(context, bookProvider);
                  },
                ),
            ],
          ),
          // Added RefreshIndicator so you can manually pull down to refresh if the 
          // automatic sync didn't catch the data in time.
          body: RefreshIndicator(
            onRefresh: () => bookProvider.fetchHistory(),
            child: bookProvider.isLoading && history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                    ? ListView( // Using ListView here so pull-to-refresh works even when empty
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.history, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 10),
                                Text(
                                  "No history found.",
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () => bookProvider.fetchHistory(),
                                  child: const Text("Tap to Refresh"),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          return _buildHistoryCard(item, bookProvider.baseUrl);
                        },
                      ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, BookProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Clear History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Do you want to delete all rental history?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearHistory();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Text("Clear All", style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic item, String baseUrl) {
    final String rawPath = item['coverImage'] ?? item['bookImage'] ?? item['image'] ?? '';
    
    String finalImageUrl = "";
    if (rawPath.isNotEmpty) {
      if (rawPath.startsWith('http')) {
        finalImageUrl = rawPath; 
      } else {
        finalImageUrl = "$baseUrl${rawPath.startsWith('/') ? '' : '/'}$rawPath";
      }
    }

    final String title = item['bookTitle'] ?? item['title'] ?? "Unknown Title";
    final String authorName = item['bookAuthor'] ?? item['author'] ?? "Unknown Author";
    
    final String rawReturnDate = item['actualReturnDate'] ?? item['returnDate'] ?? 'N/A';
    final String returnDisplayDate = rawReturnDate.split('T')[0]; 
    
    final String rawRentDate = item['rentDate'] ?? 'N/A';
    final String rentDisplayDate = rawRentDate.split('T')[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: finalImageUrl.isNotEmpty
                ? Image.network(
                    finalImageUrl,
                    width: 50,
                    height: 70,
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
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  authorName,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                const Divider(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rented: $rentDisplayDate",
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "Returned: $returnDisplayDate",
                        style: GoogleFonts.poppins(
                          fontSize: 10, 
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 70,
      color: Colors.grey[200],
      child: const Icon(Icons.book, color: Colors.grey, size: 30),
    );
  }
}