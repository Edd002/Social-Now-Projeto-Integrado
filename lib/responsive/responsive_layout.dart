import 'package:flutter/material.dart';
import 'package:social_now_projeto_integrado/providers/user_provider.dart';
import 'package:social_now_projeto_integrado/utils/global_variable.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget mobileScreenLayout;
  final Widget webScreenLayout;
  const ResponsiveLayout({
    Key? key,
    required this.mobileScreenLayout,
    required this.webScreenLayout,
  }) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        // 600 pode ser alterado para 900 se você quiser exibir a tela do tablet com o layout da tela do celular
        return widget.webScreenLayout;
      }
      return widget.mobileScreenLayout;
    });
  }
}
