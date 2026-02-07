import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> _faqData = [
    {"q": "How long can I keep a rented book?", "a": "The standard rental period is 14 days. You can renew once if no one else has reserved it."},
    {"q": "How many books can I rent at once?", "a": "Standard users can rent up to 5 books simultaneously."},
    {"q": "Are there late fees?", "a": "Yes, a fee of \$0.50 per day is applied to overdue books."},
    {"q": "How do I return a book?", "a": "Go to 'My Rentals' in the app and click the 'Return' button, then drop the physical book at the library kiosk."},
    {"q": "Can I reserve a book that is currently out?", "a": "Yes, you can place a hold on any book through its detail page."},
    {"q": "Do you offer digital E-books?", "a": "Currently, LibraRead focuses on physical inventory, but E-books are coming in a future update!"},
    {"q": "How do I update my profile email?", "a": "Navigate to Account Settings > Change E-mail to update your contact information."},
    {"q": "What should I do if I lose a book?", "a": "Please contact the library staff immediately. Lost books incur a replacement fee plus a small processing charge."},
    {"q": "Can I donate books to LibraRead?", "a": "Absolutely! We accept donations at the main desk during operating hours."},
    {"q": "Where is the library located?", "a": "Our main branch is located at 123 Reading Lane, Booktown."},
    {"q": "Is there a quiet study area?", "a": "Yes, the second floor is a dedicated silent zone for study and research."},
    {"q": "How do I print documents?", "a": "Printers are available near the computer lab. Standard rates are \$0.10 per page."},
    {"q": "Do you have Wi-Fi?", "a": "Yes, free high-speed Wi-Fi is available for all registered members."},
    {"q": "Can I suggest a book for the library to buy?", "a": "Yes! Use the 'Suggest a Book' form in the app footer."},
    {"q": "Are there children's storytelling sessions?", "a": "Yes, every Saturday at 10:00 AM in the Children's Corner."},
    {"q": "How do I reset my password?", "a": "Use the 'Change Password' option in your Account Settings."},
    {"q": "Can someone else pick up my books?", "a": "Only if you have added them as an authorized proxy in your account settings."},
    {"q": "Is my reading history private?", "a": "Yes, we prioritize your privacy. Only you can view your past rentals."},
    {"q": "Do you offer research assistance?", "a": "Our librarians are available for 1-on-1 research help by appointment."},
    {"q": "What are the library hours?", "a": "We are open Monday-Friday 8 AM - 8 PM, and Saturday 10 AM - 4 PM."},
  ];

  late List<bool> _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = List.generate(_faqData.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: AppBar(
        title: Text("Library FAQ", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpansionPanelList(
            elevation: 0, // Keeps it clean
            dividerColor: Colors.grey[200],
            expansionCallback: (index, isExpanded) {
              setState(() {
                _isOpen[index] = isExpanded;
              });
            },
            children: _faqData.asMap().entries.map((entry) {
              int idx = entry.key;
              var item = entry.value;
              return ExpansionPanel(
                canTapOnHeader: true,
                backgroundColor: _isOpen[idx] ? Colors.orange.withOpacity(0.05) : Colors.white,
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(item['q']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isExpanded ? Colors.orange : Colors.black87,
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Text(item['a']!,
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.5, color: Colors.grey[700]),
                  ),
                ),
                isExpanded: _isOpen[idx],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}