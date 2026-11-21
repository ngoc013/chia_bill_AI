import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../core/constants/app_constants.dart';
import '../models/bank_model.dart';
import '../services/vietqr_service.dart';

// 1. Tạo Provider cung cấp dịch vụ VietQRService cho toàn bộ ứng dụng
final vietQRServiceProvider = Provider<VietqrService>((ref) {
  return VietqrService(); // Khởi tạo một bản thể duy nhất của VietQRService
});

// 2. Tạo FutureProvider quản lý danh sách ngân hàng (tự động xử lý Loading / Data / Error)
final bankListProvider = FutureProvider<List<BankModel>>((ref) async {
  // Mở sẵn ngăn chứa bộ nhớ đệm ngân hàng từ Hive
  final cacheBox = Hive.box(AppConstants.banksCacheBox);

  // Lấy dịch vụ gọi API VietQR ở trên xuống để dùng
  final vietQRService = ref.read(vietQRServiceProvider);

  try {
    // Bước A: Gọi API VietQR để tải danh sách ~60 ngân hàng mới nhất về
    final freshBanks = await vietQRService.fetchBank();

    // Bước B: Chuyển danh sách thành dạng Map và lưu đè vào Hive để dùng khi offline
    final banksAsMaps = freshBanks.map((bank) => bank.toMap()).toList();
    await cacheBox.put('cached_banks_list', banksAsMaps);

    // Trả về danh sách ngân hàng mới nhất cho giao diện hiển thị
    return freshBanks;
  } catch (e) {
    // Bước C: Nếu mất mạng hoặc API lỗi -> Đọc lại dữ liệu cũ đã lưu trong Hive
    final cachedData = cacheBox.get('cached_banks_list');

    if (cachedData != null && cachedData is List) {
      // Ép kiểu từng phần tử từ Hive về lại đối tượng BankModel
      return cachedData.map((item) => BankModel.fromMap(Map<String, dynamic>.from(item))).toList();
    }

    // Nếu cả mạng lẫn bộ nhớ đệm đều trống (lần đầu mở app mà không có mạng) -> Báo lỗi
    rethrow;
  }
});