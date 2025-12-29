class CollegeModel {
  final int id;
  final String name;
  final String district;
  final String province;

  CollegeModel({
    required this.id,
    required this.name,
    required this.district,
    required this.province,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      id: json['id'],
      name: json['name'],
      district: json['district'] ?? '',
      province: json['province'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'province': province,
    };
  }

  @override
  String toString() => name;
}
