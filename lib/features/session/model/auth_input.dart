class AuthInput {
  final int? pin;
  final String? qrCode;
  final String? nfcTag;

  const AuthInput._({this.pin, this.qrCode, this.nfcTag});

  factory AuthInput.pin(int pin) => AuthInput._(pin: pin);
  factory AuthInput.qr(String qrCode) => AuthInput._(qrCode: qrCode);
  factory AuthInput.nfc(String nfcTag) => AuthInput._(nfcTag: nfcTag);
}
