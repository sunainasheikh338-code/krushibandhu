class TractorModel {
  final String ownerName;
  final String tractorModel;
  final String location;
  final double rentPerHour;
  final String mobileNumber;

  TractorModel({
    required this.ownerName,
    required this.tractorModel,
    required this.location,
    required this.rentPerHour,
    required this.mobileNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'tractorModel': tractorModel,
      'location': location,
      'rentPerHour': rentPerHour,
      'mobileNumber': mobileNumber,
    };
  }

  factory TractorModel.fromMap(Map<String, dynamic> map) {
    return TractorModel(
      ownerName: map['ownerName'] ?? '',
      tractorModel: map['tractorModel'] ?? '',
      location: map['location'] ?? '',
      rentPerHour: (map['rentPerHour'] ?? 0).toDouble(),
      mobileNumber: map['mobileNumber'] ?? '',
    );
  }
}