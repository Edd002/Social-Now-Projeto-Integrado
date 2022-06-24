import 'package:social_now_projeto_integrado/resources/firebase_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_now_projeto_integrado/providers/user_provider.dart';
import 'package:social_now_projeto_integrado/responsive/mobile_screen_layout.dart';
import 'package:social_now_projeto_integrado/responsive/responsive_layout.dart';
import 'package:social_now_projeto_integrado/responsive/web_screen_layout.dart';
import 'package:social_now_projeto_integrado/screens/login_screen.dart';
import 'package:social_now_projeto_integrado/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o aplicativo com base na plataforma - web ou móvel
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: API_KEY,
          appId: APP_ID,
          messagingSenderId: MESSAGING_SENDER_ID,
          projectId: PROJECT_ID,
          storageBucket: STORAGE_BUCKET),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social Now',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Verificando se o snapshot tem algum dado ou não
              if (snapshot.hasData) {
                // Se o snapshot tiver dados, o que significa que o usuário está conectado, verificamos a largura da tela e exibimos o layout da tela de acordo
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // Significa que a conexão com o futuro ainda não foi feita
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
