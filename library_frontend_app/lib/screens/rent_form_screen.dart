import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart'; // ADDED: Need AuthProvider to get current user info
import 'main_navigation.dart'; 

class RentFormScreen extends StatefulWidget {
  final dynamic book;

  const RentFormScreen({super.key, required this.book});

  @override
  State<RentFormScreen> createState() => _RentFormScreenState();
}

class _RentFormScreenState extends State<RentFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  
  String _rentDate = "mm-dd-yy";
  String _returnDate = "mm-dd-yy";
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // FIX: Auto-fill the form with the logged-in user's data
    // This ensures that by default, the email matches the account.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        _nameController.text = auth.user!['username'] ?? "";
        _emailController.text = auth.user!['email'] ?? "";
      }
    });
  }

  bool _isFormValid() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _districtController.text.trim().isEmpty) {
      _showErrorSnackBar("Please fill in all text fields.");
      return false;
    }
    if (_rentDate == "mm-dd-yy" || _returnDate == "mm-dd-yy") {
      _showErrorSnackBar("Please select both Rent and Return dates.");
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isRentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isRentDate) {
          _rentDate = formattedDate;
        } else {
          _returnDate = formattedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: Text("Form", 
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ),
            const SizedBox(height: 40),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  _buildInputField("Fullname", _nameController),
                  const SizedBox(height: 20),
                  _buildInputField("E-mail", _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildInputField("Number", _numberController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildInputField("District", _districtController),
                  const SizedBox(height: 20),
                  _buildDatePicker("Rent Date", _rentDate, () => _selectDate(context, true)),
                  const SizedBox(height: 20),
                  _buildDatePicker("Return Date", _returnDate, () => _selectDate(context, false)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    if (!_isFormValid()) return;

                    setState(() => _isSubmitting = true);
                    final bookProvider = Provider.of<BookProvider>(context, listen: false);
                    final auth = Provider.of<AuthProvider>(context, listen: false);

                    // DATA SAFETY: Added 'userId' to the payload
                    // This is the "Anchor" that ensures persistence even if the email field is changed.
                    Map<String, dynamic> rentalData = {
                      "userId": auth.user?['id'], // CRITICAL FIX: Link to account ID
                      "bookId": widget.book['_id'],
                      "bookTitle": widget.book['title'] ?? widget.book['bookTitle'] ?? "Unknown Title",
                      "renterName": _nameController.text.trim(),
                      "email": _emailController.text.trim(),
                      "phone": _numberController.text.trim(),
                      "district": _districtController.text.trim(),
                      "rentDate": _rentDate,
                      "returnDate": _returnDate,
                      "coverImage": widget.book['coverImage'] ?? widget.book['image'] ?? "", 
                      "author": widget.book['author'] ?? widget.book['bookAuthor'] ?? "Unknown Author",
                    };

                    bool success = await bookProvider.rentBook(rentalData);
                    
                    if (!mounted) return;
                    setState(() => _isSubmitting = false);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Success! Book rented."), backgroundColor: Colors.green),
                      );
                      
                      Navigator.pop(context); 
                      navKey.currentState?.setTab(1); 
                    } else {  
                      _showErrorSnackBar("Error: Could not rent book.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    elevation: 8,
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text("RENT", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: "Required",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String dateText, VoidCallback onTap) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateText, style: GoogleFonts.poppins(color: dateText == "mm-dd-yy" ? Colors.grey[600] : Colors.black, fontSize: 13)),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}