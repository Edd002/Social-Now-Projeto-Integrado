import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_now_projeto_integrado/screens/add_post_screen.dart';
import 'package:social_now_projeto_integrado/screens/feed_screen.dart';
import 'package:social_now_projeto_integrado/screens/profile_screen.dart';
import 'package:social_now_projeto_integrado/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text(''), // Notificações/Curtidas
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
