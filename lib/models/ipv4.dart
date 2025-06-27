class IPv4 {
  final int octet1;
  final int octet2;
  final int octet3;
  final int octet4;

  IPv4(this.octet1, this.octet2, this.octet3, this.octet4);

  factory IPv4.fromString(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) throw FormatException('Formato IPv4 inválido');
    return IPv4(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      int.parse(parts[3]),
    );
  }

  @override
  String toString() => '$octet1.$octet2.$octet3.$octet4';
}