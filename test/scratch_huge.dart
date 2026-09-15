import 'dart:io';

void main() {
  final file = File('A:/flutter_cache/Pub/Cache/hosted/pub.dev/hugeicons-1.1.7/lib/hugeicons.dart');
  final lines = file.readAsLinesSync();
  final staticLines = lines.where((l) => l.contains('static const List<List<dynamic>> strokeRounded')).toList();

  print('Total strokeRounded icons: ${staticLines.length}');

  void searchKeywords(String kw) {
    print('--- Search "$kw" ---');
    final matches = staticLines.where((l) => l.toLowerCase().contains(kw.toLowerCase())).take(15).toList();
    for (var m in matches) {
      print(m.trim());
    }
  }

  searchKeywords('burg');
  searchKeywords('food');
  searchKeywords('fish');
  searchKeywords('wine');
  searchKeywords('drink');
  searchKeywords('train');
  searchKeywords('park');
  searchKeywords('receipt');
  searchKeywords('invoice');
  searchKeywords('trophy');
  searchKeywords('award');
  searchKeywords('pizza');
  searchKeywords('cream');
}
