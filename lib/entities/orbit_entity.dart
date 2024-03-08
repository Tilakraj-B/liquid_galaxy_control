import 'looking_at_entity.dart';

class OrbitEntity {
  final LookingAtEntity lookAt;

  OrbitEntity(this.lookAt);

  /// Generates the `orbit` tag based on the given looking at.
  String tag() {
    String content = '';

    double heading = lookAt.heading;
    int orbit = 0;

    while (orbit <= 36) {
      if (heading >= 360) {
        heading -= 360;
      }

      content += '''
            <gx:FlyTo>
              <gx:duration>1.2</gx:duration>
              <gx:flyToMode>smooth</gx:flyToMode>
              ${lookAt.tag}
            </gx:FlyTo>
          ''';

      heading += 10;
      orbit += 1;
    }

    return content;
  }
}
