import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'butterfly_particles.dart';
import 'leaf_particles.dart';
import 'npc_component.dart';
import 'npc_data.dart';
import 'player_component.dart';
import 'scenery_component.dart';
import 'sfx.dart';
import 'station_component.dart';
import 'station_data.dart';
import 'station_scenery_component.dart';
import 'styled_joystick.dart';

/// Owns the open-world map, camera, player, stations and NPCs. Has no
/// knowledge of [Navigator] — it only exposes [nearbyStation]/[nearbyNpc]
/// and calls [onInteract]/[onInteractNpc], leaving all UI concerns to the
/// widget layer.
class WorldGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  WorldGame({required this.onInteract, required this.onInteractNpc});

  final void Function(StationData station) onInteract;
  final void Function(NpcData npc) onInteractNpc;

  late final PlayerComponent player;
  late final JoystickComponent joystick;

  /// The station the player is currently standing near, if any. Exposed as a
  /// [ValueNotifier] (rather than Flame's overlay system) so it can be
  /// observed directly from a widget with [ValueListenableBuilder] and
  /// unit-tested without needing a real [GameWidget].
  final ValueNotifier<StationData?> nearbyStationNotifier = ValueNotifier(null);
  StationData? get nearbyStation => nearbyStationNotifier.value;

  /// The NPC the player is currently standing near, if any. Same pattern as
  /// [nearbyStationNotifier].
  final ValueNotifier<NpcData?> nearbyNpcNotifier = ValueNotifier(null);
  NpcData? get nearbyNpc => nearbyNpcNotifier.value;

  @override
  Color backgroundColor() => const Color(0xFF8BC98F);

  @override
  Future<void> onLoad() async {
    unawaited(Sfx.preload());

    world.add(
      RectangleComponent(
        size: kWorldSize,
        paint: Paint()..color = const Color(0xFF8BC98F),
      ),
    );
    world.add(SceneryComponent());
    world.add(StationSceneryComponent());

    for (final data in kStations) {
      world.add(StationComponent(data: data));
    }

    for (final data in kNpcs) {
      world.add(NpcComponent(data: data));
    }

    player = PlayerComponent(position: kWorldSize / 2);
    world.add(player);
    // maxSpeed keeps the camera slightly behind the player instead of
    // snapping to its position every frame, giving it a soft chase feel.
    camera.follow(player, maxSpeed: PlayerComponent.speed * 1.6, snap: true);

    joystick = buildStyledJoystick(margin: const EdgeInsets.only(left: 32, bottom: 32));
    camera.viewport.add(joystick);
    camera.viewport.add(LeafSpawnerComponent());
    camera.viewport.add(ButterflySpawnerComponent());
  }

  /// Re-checks each station's "already played" badge. Call this after
  /// returning from a minigame, since finishing one may have set a new best
  /// score.
  void refreshStationProgress() {
    for (final station in world.children.whereType<StationComponent>()) {
      station.refreshPlayed();
    }
  }

  void setNearbyStation(StationData station) {
    if (nearbyStationNotifier.value?.id != station.id) Sfx.chime();
    nearbyStationNotifier.value = station;
  }

  void clearNearbyStation(StationData station) {
    if (nearbyStationNotifier.value?.id == station.id) {
      nearbyStationNotifier.value = null;
    }
  }

  void setNearbyNpc(NpcData npc) {
    nearbyNpcNotifier.value = npc;
  }

  void clearNearbyNpc(NpcData npc) {
    if (nearbyNpcNotifier.value?.id == npc.id) {
      nearbyNpcNotifier.value = null;
    }
  }

  /// Stations take priority: if the player is somehow in range of both at
  /// once, opening a minigame is the more consequential action.
  void interact() {
    final station = nearbyStationNotifier.value;
    if (station != null) {
      onInteract(station);
      return;
    }
    final npc = nearbyNpcNotifier.value;
    if (npc != null) onInteractNpc(npc);
  }

  @override
  void onRemove() {
    nearbyStationNotifier.dispose();
    nearbyNpcNotifier.dispose();
    super.onRemove();
  }
}
