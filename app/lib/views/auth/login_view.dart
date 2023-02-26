import 'package:auth_buttons/auth_buttons.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/providers/auth.dart';
import 'package:comein/views/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, this.returnBack});
  final bool? returnBack;
  @override
  State<LoginView> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  final PageController _controller = PageController(initialPage: 0);
  late Size size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color.fromRGBO(25, 25, 112, 1),
                  Colors.black,
                ],
              ),
            ),
          ),
          Column(
            children: const [
              // Image.asset(
              //   "assets/images/LoadingScreen.png",
              //   height: MediaQuery.of(context).size.height,
              // ),
              Spacer(),
            ],
          ),
          SafeArea(
            child: Card(
              color: Theme.of(context).cardColor.withOpacity(0.7),
              semanticContainer: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 1,
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                width: size.width - 20,
                height: 310,
                child: PageView(
                  controller: _controller,
                  children: [
                    signInList(),
                    if (!(context.read<User?>()?.isAnonymous ?? false))
                      signInSheet()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() => const Center(child: CircularProgressIndicator());

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();

  Widget signInSheet() => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _controller.previousPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                    ),
                  ),
                  const Spacer(),
                  PlatformTextButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => const SignUpScreen(),
                      isScrollControlled: true,
                    ).then((_) => (widget.returnBack ?? false)
                        ? Navigator.of(context).pop()
                        : null),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Icon(Icons.person), Text('Sign Up')],
                    ),
                  ),
                  PlatformTextButton(
                    color: Colors.purple,
                    onPressed: () async {
                      String? s = await context
                          .read<AuthenticationService>()
                          .forgotPassword(email: emailController.text.trim());
                      emailController.clear();
                      passwordController.clear();
                      if (s != "sent") {
                        showPlatformDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              PlatformAlertDialog(
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
                      } else {
                        showPlatformDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              PlatformAlertDialog(
                            title: const Text('Success'),
                            content: Text(
                              'Reset email sent',
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
                    },
                    child: const Text(
                      "Forgot Password",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            PlatformTextField(
              textInputAction: TextInputAction.next,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: "Email",
            ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            PlatformTextField(
              textInputAction: TextInputAction.next,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              hintText: "Password",
              obscureText: true,
            ),
            const Padding(
              padding: EdgeInsets.all(5),
            ),
            PlatformTextButton(
              color: Colors.green,
              onPressed: () async {
                String? s = await context.read<AuthenticationService>().signIn(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );
                emailController.clear();
                passwordController.clear();
                if (s != "Signed in") {
                  showPlatformDialog(
                    context: context,
                    builder: (BuildContext context) => PlatformAlertDialog(
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
              },
              child: const Text("Sign In"),
            ),
          ],
        ),
      );

  Widget signInList() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (context.read<User?>()?.isAnonymous ?? false)
            PlatformTextButton(
              color: CupertinoColors.systemBlue,
              onPressed: () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_back_ios_new_sharp),
                  Text('Back')
                ],
              ),
            ),
          PlatformTextButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SignUpScreen(),
              isScrollControlled: true,
            ).then((_) => (widget.returnBack ?? false)
                ? Navigator.of(context).pop()
                : null),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Icon(Icons.person), Text('Sign Up')],
            ),
          ),
          if (!(context.read<User?>()?.isAnonymous ?? false))
            PlatformTextButton(
              color: CupertinoColors.systemBlue,
              onPressed: () => showPlatformDialog(
                context: context,
                builder: (context) => PlatformAlertDialog(
                  title: const Text('Anonymously Sign In?'),
                  content: const Text('This has limited functionality'),
                  actions: [
                    PlatformDialogAction(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    PlatformDialogAction(
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: NewPlatform.isAndroid
                              ? Colors.red
                              : CupertinoColors.systemRed,
                        ),
                      ),
                      onPressed: () => context
                          .read<AuthenticationService>()
                          .signInWithAnonymous()
                          .then((_) => Navigator.pop(context)),
                    ),
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.visibility_off),
                  Text('Sign In Anonymously')
                ],
              ),
            ),
          GoogleAuthButton(
            onPressed: () => context
                .read<AuthenticationService>()
                .signInWithGoogle()
                .then((_) => widget.returnBack ?? false
                    ? Navigator.of(context).pop()
                    : null),
            themeMode: ThemeMode.dark,
            style: AuthButtonStyle(
              iconSize: 20,
              textStyle: const TextStyle(fontSize: 14, color: Colors.white),
              width: size.width - 80,
            ),
          ),
          if (NewPlatform.isIOS)
            AppleAuthButton(
              onPressed: () => context
                  .read<AuthenticationService>()
                  .signInWithApple()
                  .then((_) => widget.returnBack ?? false
                      ? Navigator.of(context).pop()
                      : null),
              themeMode: ThemeMode.dark,
              style: AuthButtonStyle(
                iconSize: 20,
                width: size.width - 80,
              ),
            ),
          if (!(context.read<User?>()?.isAnonymous ?? false))
            EmailAuthButton(
              onPressed: () {
                setState(
                  () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear,
                    );
                  },
                );
              },
              style: AuthButtonStyle(
                iconSize: 20,
                textStyle: const TextStyle(fontSize: 14),
                width: size.width - 80,
              ),
            ),
        ],
      );
}
