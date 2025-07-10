import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dsfut_provider.dart';
import '../models/player.dart';

class AvailablePlayersScreen extends StatelessWidget {
  const AvailablePlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Players'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<DsfutProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.refreshAvailablePlayers,
              );
            },
          ),
        ],
      ),
      body: Consumer<DsfutProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildStatsCard(provider),
              Expanded(child: _buildPlayersList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(DsfutProvider provider) {
    final stats = provider.playerStats;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Overview (${provider.selectedConsole.toUpperCase()})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatChip('Total', stats['total'] ?? 0, Colors.blue),
                _buildStatChip('Special', stats['special'] ?? 0, Colors.purple),
                _buildStatChip(
                  '85+ Rated',
                  stats['high_rated'] ?? 0,
                  Colors.orange,
                ),
                _buildStatChip(
                  'Under 50k',
                  stats['under_50k'] ?? 0,
                  Colors.green,
                ),
                _buildStatChip(
                  '50k-100k',
                  stats['50k_100k'] ?? 0,
                  Colors.amber,
                ),
                _buildStatChip(
                  'Over 100k',
                  stats['over_100k'] ?? 0,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: color.withOpacity(0.8),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPlayersList(DsfutProvider provider) {
    final filteredPlayers = provider.filteredAvailablePlayers;

    if (filteredPlayers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No players match your criteria'),
            Text('Try adjusting your price range or console selection'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlayers.length,
      itemBuilder: (context, index) {
        final player = filteredPlayers[index];
        return _buildDetailedPlayerCard(player);
      },
    );
  }

  Widget _buildDetailedPlayerCard(DetailedPlayer player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Player image with rating overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        player.image,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.person, size: 40),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getRatingColor(player.rating),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          player.rating.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Player details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            player.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (player.isSpecial) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SPECIAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        player.fullDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(player.position, Colors.blue),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            player.console.toUpperCase(),
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${player.price}k',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Buy: ${player.buyPrice}k',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${player.dsfutStartSecondsAgo}s ago',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Player attributes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttributeColumn('PAC', player.info.attr1),
                _buildAttributeColumn('SHO', player.info.attr2),
                _buildAttributeColumn('PAS', player.info.attr3),
                _buildAttributeColumn('DRI', player.info.attr4),
                _buildAttributeColumn('DEF', player.info.attr5),
                _buildAttributeColumn('PHY', player.info.attr6),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttributeColumn(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getAttributeColor(value),
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 90) return Colors.purple;
    if (rating >= 85) return Colors.orange;
    if (rating >= 80) return Colors.yellow.shade700;
    if (rating >= 75) return Colors.green;
    return Colors.grey;
  }

  Color _getAttributeColor(int attribute) {
    if (attribute >= 90) return Colors.green;
    if (attribute >= 80) return Colors.orange;
    if (attribute >= 70) return Colors.amber;
    return Colors.grey;
  }
}
