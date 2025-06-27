class SubnetMask {
  final int octet1;
  final int octet2;
  final int octet3;
  final int octet4;

  SubnetMask(this.octet1, this.octet2, this.octet3, this.octet4);

  factory SubnetMask.fromString(String mask) {
    if (mask.startsWith('/')) {
      return _fromPrefixLength(int.parse(mask.substring(1)));
    } else {
      final parts = mask.split('.');
      if (parts.length != 4) throw FormatException('Formato de máscara inválido');
      return SubnetMask(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        int.parse(parts[3]),
      );
    }
  }

  static SubnetMask _fromPrefixLength(int prefix) {
    if (prefix < 0 || prefix > 32) throw ArgumentError('Prefix deve estar entre 0 e 32');
    var mask = List.filled(4, 0);
    for (var i = 0; i < prefix; i++) {
      mask[i ~/ 8] += 1 << (7 - (i % 8));
    }
    return SubnetMask(mask[0], mask[1], mask[2], mask[3]);
  }

  @override
  String toString() => '$octet1.$octet2.$octet3.$octet4';
}