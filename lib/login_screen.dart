import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_ownapi/news_list_screen.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  //facebook login to be implemented later after firebase configuration
  // Future<void> _signInWithFacebook(BuildContext context) async {
  //   try {
  //     // Attempt Facebook login
  //     final result = await FacebookAuth.instance.login();

  //     if (result.status == LoginStatus.success) {
  //       // Successfully logged in, no need to manually handle the token
  //       final accessToken = result.accessToken;

  //       if (accessToken != null) {
  //         // Sign in with Firebase using Facebook's access token
  //         final OAuthCredential credential =
  //             FacebookAuthProvider.credential(accessToken.token);
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //         // Navigate to the next screen upon successful login
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => const NewsListScreen()),
  //         );
  //       }
  //     } else {
  //       // Handle the failure case
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Facebook sign-in failed: ${result.message}')),
  //       );
  //     }
  //   } catch (e) {
  //     // Handle errors
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error during Facebook sign-in: $e')),
  //     );
  //   }
  // }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> _loginUser(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null; // Success
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Future<String?> _signUpUser(SignupData data) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      return null; // Success
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      // Send the password reset email using Firebase Auth
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Success message
    } catch (e) {
      return handleAuthError(e); // Handle errors (e.g., email not found)
    }
    return null;
  }

// Error handling function for Firebase Authentication errors
  String handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with that email address.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'An error occurred. Please try again later.';
      }
    } else {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google sign-in aborted';
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return null; // Success
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  String _handleAuthError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered. Please use another.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'An unknown error occurred: ${e.message}';
      }
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterLogin(
          title: 'News Login',
          onLogin: _loginUser,
          onSignup: _signUpUser,
          onRecoverPassword: _recoverPassword,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const NewsListScreen()),
            );
          },
          theme: LoginTheme(
            primaryColor: Colors.blue,
            accentColor: Colors.white,
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // To space the buttons
            children: [
              // Google Sign-In Button
              ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google     '),
                onPressed: () async {
                  String? result = await _signInWithGoogle();
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const NewsListScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFDB4437), // Google's red color
                  foregroundColor: Colors.white, // White text and icon
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Facebook Sign-In Button
              ElevatedButton.icon(
                icon: const Icon(Icons.facebook),
                label: const Text('Facebook'),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Facebook button color
                  foregroundColor: Colors.white, // White text and icon
                ),
)



            ],
          ),
        ),
      ],
    );
  }
}
