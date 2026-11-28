import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bank_model.dart';
import '../models/user_profile_model.dart';
import '../providers/bank_provider.dart';
import '../providers/profile_provider.dart';

class BankProfileScreen extends ConsumerStatefulWidget {
  const BankProfileScreen({super.key});
  @override
  ConsumerState<BankProfileScreen> createState() => _BankProfileScreenState();
}

class _BankProfileScreenState extends ConsumerState<BankProfileScreen> {
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _friendNameController = TextEditingController();

  BankModel? _selectedBank;
  bool _isInitialized = false;
  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _friendNameController.dispose();
    super.dispose();
  }

  Future<void> _saveBankProfile() async {
    final accountName = _accountNameController.text.trim().toUpperCase();
    final accountNumber = _accountNumberController.text.trim();
    if (_selectedBank == null || accountName.isEmpty || accountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn ngân hàng và nhập đầy đủ thông tin!"),
        ),
      );
      return;
    }

    final profile = UserBankProfile(
      accountName: accountName,
      accountNumber: accountNumber,
      bankBin: _selectedBank!.bin,
      bankShortName: _selectedBank!.shortName,
    );
    await ref.read(userProfileNotifier.notifier).saveProfile(profile);
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lưu tài khoản ngân hàng thành công"),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Future<void> _addFriend() async {
    final name = _friendNameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(friendsProvider.notifier).addFriend(name);
    _friendNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bankListAsync = ref.watch(bankListProvider);
    final savedProfile = ref.watch(userProfileNotifier);
    final friends = ref.watch(friendsProvider);
    if (!_isInitialized && savedProfile != null) {
      _accountNameController.text = savedProfile.accountName;
      _accountNumberController.text = savedProfile.accountNumber;
      _isInitialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản & Bạn bè"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Tài khoản nhận tiền của bạn",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            bankListAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) =>
                  Text("Không tải được danh sách ngân hàng:$err"),
              data: (banks) {
                if (_selectedBank == null && savedProfile != null) {
                  try {
                    _selectedBank = banks.firstWhere(
                      (b) => b.bin == savedProfile.bankBin,
                    );
                  } catch (_) {}
                }
                return DropdownButtonFormField<BankModel>(
                  value: _selectedBank,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Chọn ngân hàng",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: banks.map((bank) {
                    return DropdownMenuItem<BankModel>(
                      value: bank,
                      child: Row(
                        children: [
                          Image.network(
                            bank.logo,
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.account_balance,
                              size: 24,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${bank.shortName} - ${bank.name}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBank = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số tài khoản",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _accountNameController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Tên chủ tài khoản (Không dấu)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saveBankProfile,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Lưu tài khoản ngân hàng",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const Divider(height: 40, thickness: 1),

            const Text(
              "2. Danh bạ bạn bè chia bill",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _friendNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: "Tên bạn bè",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addFriend(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _addFriend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.person_add),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (friends.isEmpty)
              const Text(
                "Chưa có ai trong danh bạ.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: friends.map((friend) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        friend.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    label: Text(friend.name),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => ref
                        .read(friendsProvider.notifier)
                        .removeFriend(friend.id),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
