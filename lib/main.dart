import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'providers/bank_provider.dart';
import 'models/bank_model.dart';
import 'screens/bank_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.contactsBox);
  await Hive.openBox(AppConstants.billsBox);
  await Hive.openBox(AppConstants.banksCacheBox);
  runApp(const ProviderScope(child: ChiaBillApp()));
}

class ChiaBillApp extends StatelessWidget {
  const ChiaBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chia Bill AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const BankProfileScreen()
    );
  }
}