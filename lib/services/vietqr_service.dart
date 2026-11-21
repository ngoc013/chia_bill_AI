import 'package:dio/dio.dart';
import '../models/bank_model.dart';

class VietqrService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.vietqr.io/v2',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )
  );

  Future<List<BankModel>> fetchBank() async{
    try {
      final response = await _dio.get('/banks');
      if(response.statusCode == 200 && response.data['code']=='00'){
        final List<dynamic> dataList = response.data['data'] ??[];
        return dataList.map((json)=>BankModel.fromJson(json)).toList();
      }else{
        throw Exception('API VietQr trả về mã lỗi: ${response.data['desc']}');
      }
    } on DioException catch(e) {
        throw Exception('Lỗi kết nối mạng khi tải danh sách ngân hàng: ${e.message}');
      } catch(e) {
        throw Exception('Lỗi không xác định:$e');
      }
  }
  static String buildQrImageUrl({
    required String bankBin,
    required String accountNumber,
    required int amount,
    required String description,
    String accountName='',
    String template= 'compact2',
  }){
    final encodedDesc = Uri.encodeComponent(description);
    final encodedName = Uri.encodeComponent(accountName);
    return 'https://img.vietqr.io/image/$bankBin-$accountNumber-$template.png'
          '?amount=$amount'
          '&addInfo=$encodedDesc'
          '&accountName=$encodedName';
  }
}

