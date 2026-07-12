import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:save_earth/game/npc_data.dart';
import 'package:save_earth/game/station_data.dart';
import 'package:save_earth/game/world_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  StationData? interacted;
  NpcData? talkedTo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWithGame<WorldGame>(
    'entering a station radius shows it as nearby and interacting fires onInteract',
    () => WorldGame(
      onInteract: (station) => interacted = station,
      onInteractNpc: (npc) {},
    ),
    (game) async {
      await game.ready();
      game.update(0);
      interacted = null;

      final target = kStations.first;
      game.player.position = target.position.clone();
      game.update(0);
      game.update(0);

      expect(game.nearbyStation?.id, target.id);
      expect(game.nearbyStationNotifier.value?.id, target.id);

      game.interact();
      expect(interacted?.id, target.id);
    },
  );

  testWithGame<WorldGame>(
    'walking away from a station clears it as nearby',
    () => WorldGame(
      onInteract: (station) => interacted = station,
      onInteractNpc: (npc) {},
    ),
    (game) async {
      await game.ready();

      final target = kStations.first;
      game.player.position = target.position.clone();
      game.update(0);
      expect(game.nearbyStation, isNotNull);

      // Every station is at least 800px away from the map's top-left
      // corner, well outside the 70px interaction radius.
      game.player.position.setValues(0, 0);
      game.update(0);

      expect(game.nearbyStation, isNull);
    },
  );

  testWithGame<WorldGame>(
    'interacting with no nearby station does nothing',
    () => WorldGame(
      onInteract: (station) => interacted = station,
      onInteractNpc: (npc) {},
    ),
    (game) async {
      await game.ready();
      interacted = null;

      game.interact();

      expect(interacted, isNull);
    },
  );

  testWithGame<WorldGame>(
    'entering an NPC radius shows it as nearby and interacting fires onInteractNpc',
    () {
      return WorldGame(
        onInteract: (station) => interacted = station,
        onInteractNpc: (npc) => talkedTo = npc,
      );
    },
    (game) async {
      await game.ready();
      game.update(0);
      talkedTo = null;

      final npc = kNpcs.first;
      game.player.position = npc.homePosition.clone();
      game.update(0);
      game.update(0);

      expect(game.nearbyNpc?.id, npc.id);

      game.interact();
      expect(talkedTo?.id, npc.id);
    },
  );

  testWithGame<WorldGame>(
    'a nearby station takes priority over a nearby NPC when interacting',
    () {
      return WorldGame(
        onInteract: (station) => interacted = station,
        onInteractNpc: (npc) => talkedTo = npc,
      );
    },
    (game) async {
      await game.ready();
      interacted = null;
      talkedTo = null;

      game.setNearbyStation(kStations.first);
      game.setNearbyNpc(kNpcs.first);

      game.interact();

      expect(interacted?.id, kStations.first.id);
      expect(talkedTo, isNull);
    },
  );
}
