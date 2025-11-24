/// FILE: lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!valid) return;

    AuthService.register(_emailCtl.text, _passwordCtl.text);
    AuthService.markLoggedIn();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Account Created'),
        content: const Text(
          'Your account has been created successfully. '
              'Let\'s quickly show you how SuNote works.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/onboarding1');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create new Account',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('NAME'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(
                  hintText: 'Mustafa Alp Merdol',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('EMAIL'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(
                  hintText: 'name@sabanciuniv.edu',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@sabanciuniv.edu')) {
                    return 'Please use your Sabancı email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('PASSWORD'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _passwordCtl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '********',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'At least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already Registered? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Log in here.'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
