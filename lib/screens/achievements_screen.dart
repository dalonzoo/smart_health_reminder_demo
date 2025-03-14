import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/gamification_provider.dart';
import '../widgets/achievement_card.dart';


class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final achievements = gamificationProvider.achievements;
    final unlockedAchievements = gamificationProvider.unlockedAchievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events),
                      const SizedBox(width: 8),
                      Text(
                        '${unlockedAchievements.length}/${achievements.length} Unlocked',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(width: 8),
                      Text(
                        '${gamificationProvider.points} Points',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Unlocked (${unlockedAchievements.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (unlockedAchievements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Complete health tasks to unlock achievements!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: unlockedAchievements.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AchievementCard(
                      achievement: unlockedAchievements[index],
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Locked (${achievements.length - unlockedAchievements.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: achievements.length - unlockedAchievements.length,
              itemBuilder: (context, index) {
                final lockedAchievements = achievements
                    .where((achievement) => !achievement.isUnlocked)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AchievementCard(
                    achievement: lockedAchievements[index],
                    isLocked: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

