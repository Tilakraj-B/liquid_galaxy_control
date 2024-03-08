import '../entities/orbit_entity.dart';

class OrbitModel {
  final OrbitEntity entity;

  OrbitModel(this.entity);

  /// Builds and returns the `orbit` KML based on the given .
  String buildOrbit() => '''
<?xml version="1.0" encoding="UTF-8"?>
      <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
        <gx:Tour>
          <name>Orbit</name>
          <gx:Playlist> 
            ${entity.tag()}
          </gx:Playlist>
        </gx:Tour>
      </kml>
    ''';
}
