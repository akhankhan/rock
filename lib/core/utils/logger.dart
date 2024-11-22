import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger('FineRock');

  static void init() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static void log(String message, [Level level = Level.INFO]) {
    _logger.log(level, message);
  }
}
