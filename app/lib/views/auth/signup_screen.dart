import 'package:comein/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController(),
      displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool readPrivacyPolicy = false;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          color: Theme.of(context).canvasColor,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    RawMaterialButton(
                      onPressed: () {
                        emailController.clear();
                        passwordController.clear();
                        passwordConfirmController.clear();
                        displayNameController.clear();
                        Navigator.pop(context);
                      },
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.cancel,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                PlatformTextFormField(
                  controller: displayNameController,
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  hintText: "Name",
                  keyboardType: TextInputType.name,
                ),
                PlatformTextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: "Email",
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),
                PlatformTextFormField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  hintText: "Password",
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                PlatformTextFormField(
                  controller: passwordConfirmController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return "Please confirm your password";
                    } else if (val != passwordController.text) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                  hintText: "Confirm password",
                  obscureText: true,
                ),
                Row(
                  children: [
                    const Text('I have read and agree to the '),
                    TextButton(
                        onPressed: () =>
                            launchUrlString("https://www.google.com"),
                        child: const Text('terms of service')),
                    const Spacer(),
                    PlatformSwitch(
                        value: readPrivacyPolicy,
                        onChanged: (val) {
                          setState(() => readPrivacyPolicy = val);
                        }),
                  ],
                ),
                PlatformTextButton(
                  color: Colors.green,
                  onPressed: () async {
                    if (!readPrivacyPolicy) {
                      showPlatformDialog(
                        context: context,
                        builder: (context) => PlatformAlertDialog(
                          title: const Text("Terms of Service"),
                          content: const Text(
                              "You must read and agree to the terms of service before you can sign up."),
                          actions: [
                            PlatformDialogAction(
                              child: const Text("Okay"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                    if ((_formKey.currentState?.validate() ?? false) &&
                        readPrivacyPolicy) {
                      String? s =
                          await context.read<AuthenticationService>().signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                displayName: displayNameController.text.trim(),
                              );
                      if (s == "Signed up") {
                        emailController.clear();
                        passwordController.clear();
                        displayNameController.clear();
                        Navigator.of(context).pop();
                        await context.read<AuthenticationService>().signIn(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );
                      } else {
                        showPlatformDialog(
                          context: context,
                          builder: (context) => PlatformAlertDialog(
                            title: const Text('Error'),
                            content: Text(
                              s ?? 'Something went wrong',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            actions: [
                              PlatformDialogAction(
                                child: const Text('Okay'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      );
}
