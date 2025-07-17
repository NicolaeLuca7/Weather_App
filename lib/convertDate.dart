import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;

DateTime convertDate(DateTime here, double loclat, double loclon) {
  var v = tz.TZDateTime.from(
      here, tz.getLocation(tzmap.latLngToTimezoneString(loclat, loclon)));

  return v;
}
