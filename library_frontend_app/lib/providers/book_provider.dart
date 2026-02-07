import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'auth_provider.dart';

class BookProvider with ChangeNotifier {
  String get baseUrl {
    if (kIsWeb) return "http://localhost:5000"; 
    return "http://10.0.2.2:5000";
  }

  List<dynamic> _books = [];
  List<dynamic> _rentals = []; 
  List<dynamic> _history = []; 
  bool _isLoading = false;
  String? _currentUserEmail;
  String? _currentUserName; 

  List<dynamic> get books => _books;
  bool get isLoading => _isLoading;
  String? get currentUserEmail => _currentUserEmail; 
  String? get currentUserName => _currentUserName;    

  List<dynamic> get activeRentals => _rentals;
  List<dynamic> get pastRentals => _history;

  // Normalization helper
  String? get _normalizedEmail => _currentUserEmail?.trim().toLowerCase();

  void setUserData(String? email, String? username) {
    if (_currentUserEmail == email && _currentUserName == username) return;

    _currentUserEmail = email;
    _currentUserName = username ?? "User";
    
    debugPrint("👤 BookProvider Sync: $_currentUserName ($_normalizedEmail)");
    
    if (_normalizedEmail != null && _normalizedEmail!.isNotEmpty) {
      refreshAllData();
    } else {
      _rentals = [];
      _history = [];
    }
    notifyListeners(); 
  }

  Future<void> refreshAllData() async {
    await fetchBooks();
    await fetchRentals();
    await fetchHistory();
  }

  Future<void> signOut() async {
    _currentUserEmail = null;
    _currentUserName = null;
    _rentals = [];
    _history = [];
    notifyListeners();
  }

  Future<bool> deleteAccount(AuthProvider auth) async {
    _isLoading = true;
    notifyListeners();
    try {
      bool success = await auth.deleteUserAccount();
      if (success) {
        await signOut();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseUrl/admin/dashboard-data');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is List) {
          _books = decodedData;
        }
      }
    } catch (e) {
      debugPrint("🛑 FETCH BOOKS ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rentBook(Map<String, dynamic> rentalData) async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseUrl/api/rentals'); 
    try {
      rentalData['email'] = _normalizedEmail;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(rentalData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await refreshAllData(); 
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🛑 RENT BOOK ERROR: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRentals() async {
    if (_normalizedEmail == null || _normalizedEmail!.isEmpty) return;
    
    final url = Uri.parse('$baseUrl/api/my-rentals?email=$_normalizedEmail'); 
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is List) {
          _rentals = decodedData;
          debugPrint("✅ Active Rentals Loaded: ${_rentals.length}");
        }
      }
    } catch (e) {
      debugPrint("🛑 FETCH RENTALS ERROR: $e");
    }
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    if (_normalizedEmail == null || _normalizedEmail!.isEmpty) return;

    final url = Uri.parse('$baseUrl/api/my-history?email=$_normalizedEmail');
    
    _isLoading = true; 
    notifyListeners();

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      debugPrint("📡 REQUEST URL: $url");
      debugPrint("📡 SERVER RESPONSE CODE: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is List) {
          _history = decodedData;
          debugPrint("✅ History Sync: Found ${_history.length} items");
        }
      } else {
        // This is where you saw the "Cannot GET" error
        debugPrint("❌ SERVER ERROR: ${response.body}");
      }
    } catch (e) {
      debugPrint("🛑 FETCH HISTORY EXCEPTION: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    if (_normalizedEmail == null) return;
    
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseUrl/api/my-history/clear?email=$_normalizedEmail');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _history = []; 
        debugPrint("✅ Rental history cleared");
      }
    } catch (e) {
      debugPrint("🛑 CLEAR HISTORY ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> returnBook(String rentalId, String bookId) async {
    _isLoading = true;
    notifyListeners();
    
    final url = Uri.parse('$baseUrl/api/rentals/return');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rentalId': rentalId, 'bookId': bookId}),
      );
      
      if (response.statusCode == 200) {
        debugPrint("🔄 Return success. Syncing data...");
        await fetchRentals(); 
        await Future.delayed(const Duration(milliseconds: 600));
        await fetchHistory(); 
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🛑 RETURN BOOK ERROR: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}