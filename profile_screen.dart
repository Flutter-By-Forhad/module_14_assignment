import 'package:flutter/material.dart';
// FIX: The import path has been corrected to navigate up one directory first.
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String token;

  const ProfileScreen({super.key, required this.userId, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String _errorMessage = '';
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final profile = await ApiService().getProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _nameController.text = profile['first_name'] ?? '';
        _jobController.text = 'Developer'; // Example default value
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateProfile() async {
    try {
      await ApiService().updateProfile(
        widget.userId,
        _nameController.text,
        _jobController.text,
      );
      _fetchProfile(); // Refresh profile data
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _deleteAccount() async {
    try {
      await ApiService().deleteAccount(widget.userId);
      if (!mounted) return;
      // Navigate to login and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted successfully')));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              if (_profile != null) ...[
                if (_profile!['avatar'] != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(_profile!['avatar']),
                    radius: 50,
                  ),
                const SizedBox(height: 20),
                Text('Email: ${_profile!['email']}', style: const TextStyle(fontSize: 16)),
                Text('First Name: ${_profile!['first_name']}', style: const TextStyle(fontSize: 16)),
                Text('Last Name: ${_profile!['last_name']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'New Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jobController,
                  decoration: const InputDecoration(labelText: 'New Job', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profile'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete Account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy LoginScreen to make the file runnable for checking.
// You should have your own implementation in 'login_screen.dart'.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Screen')),
    );
  }
}

