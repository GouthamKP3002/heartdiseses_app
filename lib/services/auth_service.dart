import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': result.user,
        'role': role,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        await signOut();
        return {
          'success': false,
          'message': 'User data not found. Please contact support.',
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      return {
        'success': true,
        'user': result.user,
        'role': userData['role'],
        'profileCompleted': userData['profileCompleted'] ?? false,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['role'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if profile is completed
  Future<bool> isProfileCompleted(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return (userDoc.data() as Map<String, dynamic>)['profileCompleted'] ??
            false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String uid,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...profileData,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Error message helper
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}