class BankModel {
  final int id;
  final String name;
  final String code;
  final String bin;
  final String shortName;
  final String logo;
  const BankModel({
    required this.id,
    required this.name,
    required this.code,
    required this.bin,
    required this.shortName,
    required this.logo,
  });
  factory BankModel.fromJson(Map<String,dynamic> json) {
    return BankModel(
      id: json['id']?? 0,
      name: json['name']?? '',
      code: json['code']?? '',
      bin: json['bin']?? '',
      shortName: json['shortname']?? json['code']?? '',
      logo: json['logo']?? '',
    );
  }
  Map<String,dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'bin': bin,
      'shortName': shortName,
      'logo': logo,
    };
  }
  factory BankModel.fromMap(Map<String,dynamic> map) {
    return BankModel(
      id: map['id']?? 0,
      name: map['name']?? '',
      code: map['code']?? '',
      bin: map['bin']?? '',
      shortName: map['shortName']?? '',
      logo: map['logo']?? ''
    );
  }
}