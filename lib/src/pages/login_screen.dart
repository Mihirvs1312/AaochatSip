import 'package:callingproject/src/Providers/login_provider.dart';
import 'package:callingproject/src/pages/call_screen.dart';
import 'package:callingproject/src/pages/incomming_call_screen.dart';
import 'package:callingproject/src/utils/constants.dart';
import 'package:callingproject/src/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<LoginProvider>(context);
    // provider.loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    final mLoginProvider = Provider.of<LoginProvider>(context);
    OutlineInputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 2.0),
      borderRadius: BorderRadius.circular(15),
    );

    OutlineInputBorder focusBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
      borderRadius: BorderRadius.circular(15),
    );
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 500,
          width: 800,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Left Panel (Design / Logo / Branding)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/aao_logo.png',
                            height: 120,
                            width: MediaQuery.of(context).size.height * 0.3,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Sign in to continue and manage your account.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right Panel (Login Form)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black12, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Login to Your Account",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: mLoginProvider.mEmailController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            labelText: "Username",
                            enabledBorder: border,
                            focusedBorder: focusBorder,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: mLoginProvider.mPasswordController,
                          autocorrect: false,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: "Password",
                            enabledBorder: border,
                            focusedBorder: focusBorder,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<LoginProvider>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity, // Fixed width
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!provider.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.ErrorMessage ?? 'error',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final success = await provider.ApiCalling(
                                    provider.mEmailController.text.toString(),
                                    provider.mPasswordController.text
                                        .toString(),
                                  );
                                  if (success) {
                                    await SecureStorage().writebool(
                                      key: Constants.IS_LOGGEDIN,
                                      value: true,
                                    );

                                    provider.clearMyText();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CallScreenWidget(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.error ?? 'Login error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Rounded corners
                                  ),
                                  elevation: 5,
                                  // Shadow
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child:
                                    provider.isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text('Login'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ],
                    ),
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
