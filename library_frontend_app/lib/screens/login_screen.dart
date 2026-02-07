import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // 1. Perform the login
      await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Sync User Data to BookProvider immediately
      if (mounted && authProvider.user != null) {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        
        final String email = (authProvider.user!['email'] ?? '').toString();
        final String username = (authProvider.user!['username'] ?? _usernameController.text.trim()).toString();
        
        // This is the bridge that tells the BookProvider to start loading books for this specific user
        bookProvider.setUserData(email, username);
        
        // Explicitly trigger the book fetch here so they are ready when the home screen builds
        await bookProvider.fetchBooks();
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Error: ${e.toString().replaceAll("Exception: ", "")}"))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Text("Welcome To\nLibraRead!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                    children: [
                      const TextSpan(text: "CREATE A FREE\n", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      const TextSpan(text: "ACCOUNT ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      const TextSpan(text: "or log in to get\nstarted"),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text("Username", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildInput(Icons.person_add_alt_1_outlined, "username", _usernameController),
                const SizedBox(height: 20),
                Text("Password", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildInput(Icons.vpn_key_outlined, "password", _passwordController, isPass: true),
                const SizedBox(height: 15),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("dont have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text("sign up", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildLoginButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
        ],
      ),
    );
  }

  Widget _buildInput(IconData icon, String hint, TextEditingController ctr, {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: ctr,
        obscureText: isPass,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black), 
                const SizedBox(width: 5), 
                const Text("|", style: TextStyle(fontSize: 20, color: Colors.black26))
              ],
            ),
          ),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}