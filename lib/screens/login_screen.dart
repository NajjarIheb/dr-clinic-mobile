import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'doctor@clinic.com');
  final _passwordController = TextEditingController(text: 'password');
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials. Check email & password or register below.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  void _showRegisterDialog() {
    final fnCtrl = TextEditingController();
    final lnCtrl = TextEditingController();
    final specCtrl = TextEditingController(text: 'General Practice');
    final licCtrl = TextEditingController(text: 'MD-${DateTime.now().year % 100}841');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final regFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_add_alt_1, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('Register Physician'),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: regFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fnCtrl,
                          decoration: const InputDecoration(labelText: 'First Name'),
                          validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: lnCtrl,
                          decoration: const InputDecoration(labelText: 'Last Name'),
                          validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: specCtrl,
                    decoration: const InputDecoration(labelText: 'Medical Specialty'),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: licCtrl,
                    decoration: const InputDecoration(labelText: 'Medical License Number'),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Professional Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v != null && v.contains('@') ? null : 'Valid email required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Clinic Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Phone required',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!regFormKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              final success = await auth.register(
                firstName: fnCtrl.text.trim(),
                lastName: lnCtrl.text.trim(),
                specialty: specCtrl.text.trim(),
                licenseNumber: licCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              if (!mounted) return;
              if (success) {
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              }
            },
            child: const Text('Create Profile & Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.medical_services_outlined,
                      size: 80, color: AppTheme.primaryBlue),
                  const SizedBox(height: 16),
                  Text('Dr.Clinic',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text('Clinical Practice Management & EMR',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Physician Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v != null && v.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) =>
                        v != null && v.length >= 6 ? null : 'Min 6 characters',
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Sign In to Practice'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: auth.isLoading ? null : _showRegisterDialog,
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Register New Physician Account'),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '⚡ Quick Demo Access',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'doctor@clinic.com  •  password',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
