import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'providers/bank_provider.dart';
import 'models/bank_model.dart';

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
      home: TestBankScreen()
    );
  }
}
class TestBankScreen extends ConsumerWidget {
  const TestBankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái của bankListProvider (đang tải / có dữ liệu / bị lỗi)
    final bankListAsync = ref.watch(bankListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Ngân Hàng VietQR'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // Hàm .when() của Riverpod giúp xử lý gọn gàng 3 trạng thái của dữ liệu mạng
      body: bankListAsync.when(
        // 1. Trạng thái đang gọi API tải dữ liệu -> Hiện vòng xoay
        loading: () => const Center(child: CircularProgressIndicator()),

        // 2. Trạng thái lỗi (mất mạng và chưa có cache) -> Hiện thông báo lỗi
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Lỗi tải ngân hàng: $err', textAlign: TextAlign.center),
          ),
        ),

        // 3. Trạng thái thành công -> Đổ danh sách ~60 ngân hàng ra ListView
        data: (banks) => ListView.builder(
          itemCount: banks.length, // Tổng số ngân hàng tải được
          itemBuilder: (context, index) {
            final bank = banks[index]; // Lấy thông tin từng ngân hàng
            return ListTile(
              // Hiển thị logo ngân hàng từ link API (nếu ảnh lỗi thì hiện icon ngân hàng mặc định)
              leading: Image.network(
                bank.logo,
                width: 48,
                height: 48,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance),
              ),
              title: Text(bank.shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${bank.name}\nMã BIN: ${bank.bin}'),
              isThreeLine: true,
            );
          },
        ),
      ),
    );
  }
}