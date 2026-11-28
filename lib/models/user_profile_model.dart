class UserBankProfile {
  final String accountName;
  final String accountNumber;
  final String bankBin;
  final String bankShortName;
 
  const UserBankProfile({
    required this.accountName,
    required this.accountNumber,
    required this.bankBin,
    required this.bankShortName
  });

  Map<String,dynamic> toMap() {
    return {
    'accountName': accountName,
    'accountNumber': accountNumber,
    'bankBin': bankBin,
    'bankShortName': bankShortName,
  };
  }
  factory UserBankProfile.fromMap(Map<dynamic,dynamic>map){
    return UserBankProfile(
      accountName: map['accountName']?.toString() ?? '',
      accountNumber: map['accountNumber']?.toString() ?? '',
      bankBin: map['bankBin']?.toString() ?? '',
      bankShortName: map['bankShortName']?.toString() ?? '',
    );
  }
}
class FriendModel {
  final String id;
  final String name;
  
  const FriendModel({
    required this.id,
    required this.name,
  });

  Map<String,dynamic> toMap() {
    return{
      'id': id,
      'name': name,
    };
  }

  factory FriendModel.fromMap(Map<dynamic,dynamic> map){
    return FriendModel(id: map['id']?.toString() ??'',name:map['name']?.toString() ?? '');
  }
}
