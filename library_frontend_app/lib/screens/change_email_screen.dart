import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  bool _isLoading = false;

  void _saveEmail() async {
    final newEmail = _emailController.text.trim();
    final confirmEmail = _confirmEmailController.text.trim();

    // 1. Validation
    if (newEmail.isEmpty || confirmEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fields cannot be empty")));
      return;
    }
    if (newEmail != confirmEmail) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Emails do not match")));
      return;
    }

    // 2. Process Update
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateEmail(newEmail);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email updated successfully!")));
        Navigator.pop(context); // Go back to settings
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
          child: Text("Change E-mail", style: GoogleFonts.poppins(color: Colors.black, fontSize: 16)),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.network('https://cdn-icons-png.flaticon.com/512/2807/2807218.png', height: 150)),
            const SizedBox(height: 20),
            Text("Update your E-mail", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            const SizedBox(height: 40),
            _buildInputRow("New E-mail", "New E-mail", _emailController),
            const SizedBox(height: 30),
            _buildInputRow("Confirm E-mail", "Confirm E-mail", _confirmEmailController),
            const Spacer(),
            Center(
              child: _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveEmail,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, String hint, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: GoogleFonts.poppins(fontSize: 16))),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
      ],
    );
  }
}