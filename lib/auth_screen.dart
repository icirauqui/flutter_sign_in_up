import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '763661712803-n92ps1dvb3srmpju9pc0e2o2tbe7t7b9.apps.googleusercontent.com',
  );
  //final GoogleSignIn _googleSignIn = GoogleSignIn(
  //  clientId:
  //      '763661712803-au458s79q1kcfr38al24rjkamcu8nvqv.apps.googleusercontent.com',
  //);

  void _toggleView() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('Successfully signed in: ${userCredential.user!.displayName}');
      // Handle successful sign in
    } catch (e) {
      print('Error: $e');
      // Handle errors
    }
  }

  Future<void> _registerWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await userCredential.user?.updateDisplayName(
          '${_nameController.text} ${_surnameController.text}');
      // Handle successful registration
      print('User name: ${userCredential.user!.displayName}');
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      print('User name: ${googleUser.displayName}');
    } catch (e) {
      print('Error: $e');
    }
  }

//  Future<void> _signInWithApple() async {
//    try {
//      final AuthorizationCredentialAppleID credential =
//          await SignInWithApple.getAppleIDCredential(
//        scopes: [
//          AppleIDAuthorizationScopes.email,
//          AppleIDAuthorizationScopes.fullName,
//        ],
//      );
//
//      final oauthCredential = OAuthProvider("apple.com").credential(
//        idToken: credential.identityToken,
//        accessToken: credential.authorizationCode,
//      );
//
//      await _auth.signInWithCredential(oauthCredential);
//
//      print('User name: ${credential.givenName} ${credential.familyName}');
//    } catch (e) {
//      print('Error: $e');
//    }
//  }

  ButtonStyle loginButtonStyle(BuildContext context) => ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          Theme.of(context).colorScheme.surface,
        ),
        foregroundColor: WidgetStateProperty.all<Color>(
          Theme.of(context).colorScheme.onSurface,
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!_isSignIn) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                ),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: loginButtonStyle(context),
                onPressed: _isSignIn
                    ? _signInWithEmailAndPassword
                    : _registerWithEmailAndPassword,
                child: Text(_isSignIn ? 'Sign In' : 'Sign Up'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: loginButtonStyle(context),
                icon: Image.asset('assets/icons/google.png',
                    width: 20, height: 20),
                onPressed: _signInWithGoogle,
                label: Text(
                    _isSignIn ? 'Sign in with Google' : 'Sign up with Google'),
              ),
              const SizedBox(height: 20),
              //ElevatedButton.icon(
              //  style: loginButtonStyle(context),
              //  icon: const Icon(Icons.apple),
              //  onPressed: _signInWithApple,
              //  label: Text(
              //      _isSignIn ? 'Sign in with Apple' : 'Sign up with Apple'),
              //),
              //const SizedBox(height: 20),
              TextButton(
                onPressed: _toggleView,
                child: Text(
                  _isSignIn
                      ? 'Don\'t have an account? Sign up'
                      : 'Already have an account? Sign in',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
