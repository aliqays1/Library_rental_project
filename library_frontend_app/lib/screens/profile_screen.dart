import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'account_settings_screen.dart';
import 'privacy_policy_screen.dart'; 
import 'rentals_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Extracting data from the user map
    final userData = authProvider.user;
    final String displayName = userData?['username'] ?? "User";
    final String displayRole = userData?['role'] ?? "user";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Text("Profile", 
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50), 
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.only(top: 60, bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Text(displayName, 
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Account Type: ${displayRole.toUpperCase()}", 
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                top: -40,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[400],
                  child: const Icon(Icons.person, size: 60, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuOption(
                  context, 
                  Icons.privacy_tip_outlined, 
                  "Privacy Policy", 
                  const PrivacyPolicyScreen()
                ),
                
                // FIXED: Removed 'const' keyword here
                _buildMenuOption(
                  context, 
                  Icons.favorite_border, 
                  "Rentals History", 
                  RentalsHistoryScreen() 
                ),
                
                _buildMenuOption(
                  context, 
                  Icons.settings_outlined, 
                  "Account Settings", 
                  const AccountSettingsScreen()
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
                  onTap: () {
                    authProvider.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, Widget? destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, 
        style: GoogleFonts.poppins(
          fontSize: 16, 
          fontWeight: FontWeight.normal,
          color: Colors.black
        )),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title coming soon!"))
          );
        }
      },
    );
  }
}