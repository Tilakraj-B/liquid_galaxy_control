import '../entities/looking_at_entity.dart';

class LookAtModel {
  final LookingAtEntity entity;

  LookAtModel(this.entity);

  Map<String, dynamic> toMap() {
    return {
      'lng': entity.lng,
      'lat': entity.lat,
      'altitude': entity.altitude,
      'range': entity.range,
      'tilt': entity.tilt,
      'heading': entity.heading,
      'altitudeMode': entity.altitudeMode
    };
  }

  factory LookAtModel.fromMap(Map<String, dynamic> map) {
    return LookAtModel(LookingAtEntity(
        lng: map['lng'],
        lat: map['lat'],
        altitude: map['altitude'],
        range: map['range'],
        tilt: map['tilt'],
        heading: map['heading'],
        altitudeMode: map['altitudeMode']));
  }
}
