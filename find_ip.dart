import 'dart:io';

Future<void> main() async {
  final interfaces = await NetworkInterface.list(
    includeLoopback: false,
    type: InternetAddressType.IPv4,
  );

  if (interfaces.isEmpty) {
    print('No network interfaces found.');
    return;
  }

  print('Available IPv4 addresses:\n');
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      print('Interface: ${iface.name.padRight(30)} IP: ${addr.address}');
    }
  }

  print('\nLook for the interface matching your Wi-Fi adapter '
      '(skip anything named vEthernet, VirtualBox, Loopback, or VPN/Tunnel).');
  print('Then run:');
  print('  flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080');
  print('And open http://<that IP>:8080 on your iPhone.');
}
