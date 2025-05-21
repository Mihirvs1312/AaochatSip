import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ApiResponse/BasedResponse.dart';
import '../CustomWidgets/ResponsiveWidget.dart';
import '../Providers/DomainProvider.dart';
import 'LoginScreen.dart';

class Domainscreen extends StatefulWidget {
  const Domainscreen({super.key});

  @override
  State<Domainscreen> createState() => _DomainscreenState();
}

class _DomainscreenState extends State<Domainscreen> {
  @override
  Widget build(BuildContext context) {
    final mDomainProvider = Provider.of<DomainProvider>(context);
    OutlineInputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white38, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );

    OutlineInputBorder focusBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );
    // return Scaffold(
    //   backgroundColor: Colors.black,
    //   body: SafeArea(
    //     // height: MediaQuery.of(context).size.height,
    //     child: ResponsiveWidget(
    //       mobile: SingleChildScrollView(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [const logo(), DomainCard()],
    //         ),
    //       ),
    //       tablet: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Expanded(
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 const logo(),
    //                 SingleChildScrollView(
    //                   child: SizedBox(
    //                     width: MediaQuery.of(context).size.width * 0.3,
    //                     child: DomainCard(),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //       desktop: Container(
    //         width: double.infinity,
    //         padding: const EdgeInsets.all(20.0),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Expanded(
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                 crossAxisAlignment: CrossAxisAlignment.center,
    //                 children: [
    //                   const logo(),
    //                   SingleChildScrollView(
    //                     child: SizedBox(
    //                       width: MediaQuery.of(context).size.width * 0.3,
    //                       child: DomainCard(),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
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
                            'assets/logo.png',
                            height: 55,
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
                          "Welcome to Domain Portal",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: mDomainProvider.domainController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: "Domain Name",
                            enabledBorder: border,
                            focusedBorder: focusBorder,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Consumer<DomainProvider>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!provider.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(provider.ValidatorDomainMsg),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    final success =
                                        await provider.DomainApiCalling(
                                          provider.domainController.text
                                              .toString(),
                                        );
                                    if (success) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginScreen(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.error ?? 'Unknown error',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
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
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text('Submit'),
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
