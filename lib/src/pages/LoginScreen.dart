import 'package:callingproject/src/ApiResponse/BasedResponse.dart';
import 'package:callingproject/src/Providers/LoginProvider.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../CustomWidgets/ResponsiveWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Color? textColor = Theme.of(context).textTheme.bodyMedium?.color;
    Color? textLabelColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withOpacity(0.5);
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    OutlineInputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white38, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );

    OutlineInputBorder focusBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveWidget(
          mobile: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const logo(), LoginCard()],
            ),
          ),
          tablet: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const logo(),
                    SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: LoginCard(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          desktop: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const logo(),
                    SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: LoginCard(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Form LoginCard() {
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    OutlineInputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white38, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );

    OutlineInputBorder focusBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );
    return Form(
      key: _formKey,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        shadowColor: Colors.black,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to our app!",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.newline,
                autocorrect: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textFieldFill,
                  // fillColor: Colors.white38,
                  hintText: "UserName/Password",
                  border: InputBorder.none,
                  enabledBorder: border,
                  focusedBorder: focusBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.newline,
                autocorrect: false,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textFieldFill,
                  // fillColor: Colors.white38,
                  hintText: "Password",
                  border: InputBorder.none,
                  enabledBorder: border,
                  focusedBorder: focusBorder,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    // Forgot password logic
                  },
                ),
              ),
              SizedBox(height: 20),
              Consumer<LoginProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    // width: double.infinity, // Fixed width
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        final success = await provider.ApiCalling(
                          emailController.text.toString(),
                          passwordController.text.toString(),
                        );
                        if (success) {
                          await SecureStorage().writebool(
                            key: Constants.IS_LOGGEDIN,
                            value: true,
                          );

                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => HomeScreen()),
                          // );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.error ?? 'Login error'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
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
                                width: 20,
                                height: 20,
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
              SizedBox(height: 10),
              TextButton(
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                  ),
                ),
                onPressed: () {},
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Don't have an account?",
              //       style: TextStyle(color: Colors.black, fontSize: 15),
              //     ),
              //     TextButton(
              //       child: Text(
              //         "Don't have an account?Sign Up",
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontSize: 15,
              //           decoration: TextDecoration.underline,
              //           decorationColor: Colors.black,
              //         ),
              //       ),
              //       onPressed: () {},
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class logo extends StatelessWidget {
  const logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.height * 0.3,
      fit: BoxFit.none,
    );
  }
}
