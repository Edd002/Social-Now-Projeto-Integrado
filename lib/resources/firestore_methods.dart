import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_now_projeto_integrado/models/post.dart';
import 'package:social_now_projeto_integrado/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    // Perguntando uid aqui porque não queremos fazer chamadas extras para a autenticação do Firebase quando podemos apenas obter do nosso gerenciamento de estado
    String res = "Algum erro ocorreu.";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // Cria id exclusivo com base no tempo
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "Sucesso.";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Algum erro ocorreu.";
    try {
      if (likes.contains(uid)) {
        // Se a lista de curtidas contém o uid do usuário, precisamos removê-lo
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // Caso contrário, precisamos adicionar uid ao array likes
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'Sucesso.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Postar comentário
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Algum erro ocorreu.";
    try {
      if (text.isNotEmpty) {
        // Se a lista de curtidas contém o uid do usuário, precisamos removê-lo
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'Sucesso.';
      } else {
        res = "Por favor informe uma entrada.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Apague a postagem
  Future<String> deletePost(String postId) async {
    String res = "Algum erro ocorreu.";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'Sucesso.';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
