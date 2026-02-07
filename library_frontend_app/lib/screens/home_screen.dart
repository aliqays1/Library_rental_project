import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart'; // Added this
import 'book_description_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = "all";
  String _searchQuery = ""; 
  bool _isFirstLoad = true; // To prevent infinite loops

  @override
  void initState() {
    super.initState();
    // We still keep the initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<BookProvider>(context, listen: false);
        provider.fetchBooks();
        provider.fetchRentals(); 
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This triggers when the AuthProvider updates (like after a login)
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.user != null && _isFirstLoad) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      bookProvider.fetchBooks();
      bookProvider.fetchRentals();
      _isFirstLoad = false; // Only trigger this automatic sync once per session
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    List<dynamic> filteredBooks = bookProvider.books.where((book) {
      final title = (book['title'] ?? "").toString().toLowerCase().trim();
      final category = (book['category'] ?? "").toString().toLowerCase().trim();
      final searchLower = _searchQuery.toLowerCase().trim();

      bool matchesSearch = title.contains(searchLower);
      bool matchesCategory = _selectedCategory == "all" || 
                             category == _selectedCategory.toLowerCase().trim();

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await bookProvider.fetchBooks();
            await bookProvider.fetchRentals();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("HELLO DEAR, WHICH BOOK WOULD YOU LIKE TO READ TODAY?",
                    style: GoogleFonts.bebasNeue(fontSize: 22, color: Colors.grey[700])),
                const SizedBox(height: 20),
                _buildSearchBar(), 
                const SizedBox(height: 20),
                _buildCategoryFilter(),
                const SizedBox(height: 25),
                bookProvider.isLoading 
                  ? const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator()))
                  : filteredBooks.isEmpty 
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50), 
                          child: Column(
                            children: [
                              const Icon(Icons.search_off, size: 50, color: Colors.grey),
                              const SizedBox(height: 10),
                              Text("No results for '$_searchQuery'", 
                                   style: GoogleFonts.poppins(color: Colors.grey)),
                            ],
                          )
                        )
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          childAspectRatio: 0.65, 
                          crossAxisSpacing: 15, 
                          mainAxisSpacing: 15
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) => _buildBookCard(filteredBooks[index]),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.search), 
                hintText: "SEARCH BY TITLE", 
                border: InputBorder.none
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.tune, color: Colors.white),
        )
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["all", "Mystery", "Sci-Fi", "Non-Fiction", "Fiction"].map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: Colors.orange[200],
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookCard(dynamic book) {
    String status = book['availabilityStatus'] ?? book['status'] ?? "Available";
    String rating = book['rating']?.toString() ?? "0.0";
    String imageUrl = "";
    if (book['coverImage'] != null) {
      String rawPath = book['coverImage'].toString();
      String sanitizedPath = rawPath.replaceAll('\\', '/');
      imageUrl = sanitizedPath.startsWith('http') 
          ? sanitizedPath 
          : '${Provider.of<BookProvider>(context, listen: false).baseUrl}/$sanitizedPath'; 
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDescriptionScreen(book: book),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    )
                  : Container(color: Colors.grey[100], child: const Icon(Icons.book, size: 50, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book['title'] ?? "Title", 
                    style: const TextStyle(fontWeight: FontWeight.bold), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 14),
                      Text(" $rating", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: (status.toLowerCase().contains("available")) ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      status, 
                      style: TextStyle(
                        color: (status.toLowerCase().contains("available")) ? Colors.green[700] : Colors.orange[700], 
                        fontWeight: FontWeight.bold, 
                        fontSize: 11
                      )
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}