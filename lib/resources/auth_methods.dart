import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_now_projeto_integrado/models/user.dart' as model;
import 'package:social_now_projeto_integrado/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter detalhes do usuário
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Registrar User
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List? file,
  }) async {
    String res = "Algum erro ocorreu.";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // Registrando usuário em auth com e-mail e senha
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file!, false);

        model.User _user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
        );

        // Adicionando usuário em nosso banco de dados
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(_user.toJson());

        res = "Sucesso.";
      } else {
        res = "Por favor informe todos os campos.";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // Usuário de login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Algum erro ocorreu.";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // Logando usuário com e-mail e senha
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "Sucesso.";
      } else {
        res = "Por favor informe todos os campos.";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
