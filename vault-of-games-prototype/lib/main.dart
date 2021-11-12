import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vault_of_games/android.dart';
import 'package:vault_of_games/ios.dart';

void main() => runApp(const VaultOfGames());

class VaultOfGames extends StatelessWidget {
  const VaultOfGames({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Platform.isAndroid ? const AndroidApp() : const iOSApp();
}
