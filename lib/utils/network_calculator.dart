import '../models/ipv4.dart';
import '../models/subnet_mask.dart';

class NetworkCalculator {
  /// Calcula o Network ID (AND lógico entre IP e Máscara)
  static IPv4 calculateNetworkId(IPv4 ip, SubnetMask mask) {
    return IPv4(
      ip.octet1 & mask.octet1,
      ip.octet2 & mask.octet2,
      ip.octet3 & mask.octet3,
      ip.octet4 & mask.octet4,
    );
  }

  /// Calcula o Broadcast (IP OR (NOT Máscara))
  static IPv4 calculateBroadcast(IPv4 ip, SubnetMask mask) {
    return IPv4(
      ip.octet1 | (255 ^ mask.octet1),
      ip.octet2 | (255 ^ mask.octet2),
      ip.octet3 | (255 ^ mask.octet3),
      ip.octet4 | (255 ^ mask.octet4),
    );
  }

  /// Verifica se dois IPs estão na mesma rede
  static bool isSameNetwork(IPv4 ip1, IPv4 ip2, SubnetMask mask) {
    final net1 = calculateNetworkId(ip1, mask);
    final net2 = calculateNetworkId(ip2, mask);
    return net1.octet1 == net2.octet1 &&
        net1.octet2 == net2.octet2 &&
        net1.octet3 == net2.octet3 &&
        net1.octet4 == net2.octet4;
  }
} 