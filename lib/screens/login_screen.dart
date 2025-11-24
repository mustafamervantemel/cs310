/// FILE: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!valid) return;

    if (!AuthService.isRegistered) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No Account Found'),
          content: const Text(
              'There is no registered account. Please sign up first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    final success = AuthService.login(_emailCtl.text, _passwordCtl.text);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email or password is incorrect.')),
      );
      return;
    }

    // Başarılı login
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Successful'),
        content: const Text('Welcome back to SuNote!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (AuthService.onboardingCompleted) {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pushReplacementNamed(context, '/onboarding1');
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController(text: _emailCtl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forgot Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For password reset, please enter your Sabancı email. '
                  'We will send you further instructions (mock).',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@sabanciuniv.edu',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset request received (demo).'),
                ),
              );
            },
            child: const Text('Send Request'),
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
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign in to continue.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
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
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New here? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Signup !'),
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
