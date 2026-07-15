import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../game/npc_data.dart';
import '../../game/station_data.dart';
import '../../game/world_game.dart';
import '../../widgets/game_modal.dart';
import 'interact_prompt.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late final WorldGame _game = WorldGame(
    onInteract: _openMinigame,
    onInteractNpc: _talkToNpc,
  );
  final Random _random = Random();

  Future<void> _openMinigame(StationData station) async {
    _game.pauseEngine();
    await Navigator.of(context).push(
      station.isModal
          ? GameModal.modalRoute(station.screenBuilder)
          : MaterialPageRoute(builder: (_) => station.screenBuilder()),
    );
    if (mounted) {
      _game.resumeEngine();
      _game.refreshStationProgress();
    }
  }

  void _talkToNpc(NpcData npc) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorIcon(npc.icon, size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${npc.name}: ${npc.messages[_random.nextInt(npc.messages.length)]}',
                ),
              ),
            ],
          ),
          backgroundColor: npc.color.withValues(alpha: 0.95),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<WorldGame>(game: _game),
          // Soft vignette for depth; ignores touches so it never blocks input.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [Colors.transparent, Color(0x33000000)],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ),
          ValueListenableBuilder<StationData?>(
            valueListenable: _game.nearbyStationNotifier,
            builder: (context, station, _) {
              if (station != null) {
                return InteractPrompt(
                  color: station.color,
                  icon: station.icon,
                  label: 'Tocá para jugar: ${station.title}',
                  onPressed: _game.interact,
                );
              }
              // Stations take priority (see WorldGame.interact), so only
              // show the NPC prompt when no station prompt is active.
              return ValueListenableBuilder<NpcData?>(
                valueListenable: _game.nearbyNpcNotifier,
                builder: (context, npc, _) {
                  if (npc == null) return const SizedBox.shrink();
                  return InteractPrompt(
                    color: npc.color,
                    icon: PhosphorIconsFill.chatCircleDots,
                    label: 'Hablar con ${npc.name}',
                    onPressed: _game.interact,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
