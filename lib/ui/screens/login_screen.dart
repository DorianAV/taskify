import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final email = _emailController.text;

      if (_isLogin) {
        ref.read(authProvider.notifier).login(username, password);
      } else {
        ref.read(authProvider.notifier).register(username, email, password);
      }
    }
  }

  String? _getFieldError(String fieldName) {
    final validationErrors = ref.watch(authProvider).validationErrors;
    return validationErrors?[fieldName];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage != null && next.validationErrors == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Taskify',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? '¡Bienvenido de nuevo!' : 'Crear Cuenta',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _getFieldError('username'),
                  ),
                  validator: (value) => value!.isEmpty ? 'Por favor ingresa tu nombre de usuario' : null,
                ),
                const SizedBox(height: 16),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _getFieldError('email'),
                    ),
                    validator: (value) => value!.isEmpty ? 'Por favor ingresa tu correo electrónico' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _getFieldError('password'),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Por favor ingresa tu contraseña' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isLogin ? 'Iniciar sesión' : 'Registrarse',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
