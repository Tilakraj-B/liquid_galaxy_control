class LookingAtEntity {
  double lng;
  double lat;
  double altitude;
  double range;
  double tilt;
  double heading;
  String altitudeMode;

  LookingAtEntity(
      {required this.lng,
      required this.lat,
      required this.range,
      required this.tilt,
      required this.heading,
      this.altitude = 0,
      this.altitudeMode = 'relativeToGround'});

  /// Property that defines the look at tag according to its current
  /// properties.
  String get tag => '''
      <LookAt>
        <longitude>$lng</longitude>
        <latitude>$lat</latitude>
        <altitude>$altitude</altitude>
        <range>$range</range>
        <tilt>$tilt</tilt>
        <heading>$heading</heading>
        <gx:altitudeMode>$altitudeMode</gx:altitudeMode>
      </LookAt>
    ''';
}
