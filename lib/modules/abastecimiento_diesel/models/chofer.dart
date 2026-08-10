class Chofer {
  final String trabId;
  final String trabApePat;
  final String trabApeMat;
  final String trabNombres;
  final String displayText;

  Chofer({
    required this.trabId,
    required this.trabApePat,
    required this.trabApeMat,
    required this.trabNombres,
    required this.displayText,
  });

  factory Chofer.fromJson(Map<String, dynamic> json) {
    return Chofer(
      trabId: (json['trabId'] as String?)?.trim() ?? '',
      trabApePat: (json['trabApePat'] as String?)?.trim() ?? '',
      trabApeMat: (json['trabApeMat'] as String?)?.trim() ?? '',
      trabNombres: (json['trabNombres'] as String?)?.trim() ?? '',
      displayText: json['displayText'] as String? ?? '',
    );
  }
}
