import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ApiResponse/BasedResponse.dart';
import '../CustomWidgets/ResponsiveWidget.dart';
import '../Providers/DomainProvider.dart';
import '../Providers/LoginProvider.dart';
import 'LoginScreen.dart';

class Domainscreen extends StatefulWidget {
  const Domainscreen({super.key});

  @override
  State<Domainscreen> createState() => _DomainscreenState();
}

class _DomainscreenState extends State<Domainscreen> {
  final DomainInpuFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        // height: MediaQuery.of(context).size.height,
        child: ResponsiveWidget(
          mobile: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const logo(), DomainCard()],
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
                        child: DomainCard(),
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
                        child: DomainCard(),
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

  Form DomainCard() {
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
              SizedBox(
                width: double.infinity,
                child: Text(
                  "Please Enter Domain",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 20),
              Consumer<DomainProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      TextField(
                        controller: provider.domainController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.newline,
                        autocorrect: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: textFieldFill,
                          hintText: "Domain Name",
                          border: InputBorder.none,
                          enabledBorder: border,
                          focusedBorder: focusBorder,
                          errorText: provider.domainError,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        // width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!provider.validate()) {
                              return;
                            }
                            try {
                              final success = await provider.DomainApiCalling(
                                provider.domainController.text.toString(),
                              );
                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
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
                                  : const Text('Submit'),
                        ),
                      ),
                    ],
                  );
                },
              ),
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
