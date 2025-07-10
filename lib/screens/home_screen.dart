import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dsfut_provider.dart';
import '../models/player.dart';
import '../widgets/player_details_dialog.dart';
import 'available_players_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSFUT Automate'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<DsfutProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.refreshPrices,
              );
            },
          ),
        ],
      ),
      body: Consumer<DsfutProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPricesCard(provider),
                const SizedBox(height: 16),
                _buildMarketOverviewCard(context, provider),
                const SizedBox(height: 16),
                _buildControlsCard(context, provider),
                const SizedBox(height: 16),
                _buildPlayersCard(provider),
                const SizedBox(height: 16),
                _buildLogsCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPricesCard(DsfutProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Prices (1000k coins)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (provider.currentPrices != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPriceChip(
                    'Console',
                    '\$${provider.currentPrices!.console100k}',
                  ),
                  _buildPriceChip('PC', '\$${provider.currentPrices!.pc100k}'),
                ],
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChip(String label, String price) {
    return Chip(
      label: Text('$label: $price'),
      backgroundColor: Colors.green.shade100,
    );
  }

  Widget _buildControlsCard(BuildContext context, DsfutProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : provider.pickPlayer,
                  icon:
                      provider.isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.download),
                  label: Text(
                    provider.isLoading ? 'Picking...' : 'Pick Player',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      provider.isAutoPicking
                          ? provider.stopAutoPicking
                          : provider.startAutoPicking,
                  icon: Icon(
                    provider.isAutoPicking ? Icons.stop : Icons.play_arrow,
                  ),
                  label: Text(
                    provider.isAutoPicking ? 'Stop Auto' : 'Start Auto',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        provider.isAutoPicking ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, DsfutProvider provider) {
    return ExpansionTile(
      title: const Text('Settings'),
      children: [
        ListTile(
          title: const Text('Console'),
          trailing: DropdownButton<String>(
            value: provider.selectedConsole,
            items: const [
              DropdownMenuItem(value: 'ps', child: Text('PlayStation')),
              DropdownMenuItem(value: 'pc', child: Text('PC')),
            ],
            onChanged: (value) {
              if (value != null) provider.setConsole(value);
            },
          ),
        ),
        ListTile(
          title: Text(
            'Price Range: ${provider.minPrice}k - ${provider.maxPrice}k',
          ),
          subtitle: RangeSlider(
            values: RangeValues(
              provider.minPrice.toDouble(),
              provider.maxPrice.toDouble(),
            ),
            min: 1000,
            max: 200000,
            divisions: 100,
            labels: RangeLabels(
              '\$${provider.minPrice}',
              '\$${provider.maxPrice}',
            ),
            onChanged: (values) {
              provider.setPriceRange(values.start.round(), values.end.round());
            },
          ),
        ),
        ListTile(
          title: Text('Pick Interval: ${provider.pickInterval}s'),
          subtitle: Slider(
            value: provider.pickInterval.toDouble(),
            min: 3,
            max: 30,
            divisions: 27,
            label: '${provider.pickInterval}s',
            onChanged: (value) {
              provider.setPickInterval(value.round());
            },
          ),
        ),
        ListTile(
          title: Text('Take After: ${provider.takeAfter}s'),
          subtitle: Slider(
            value: provider.takeAfter.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '${provider.takeAfter}s',
            onChanged: (value) {
              provider.setTakeAfter(value.round());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersCard(DsfutProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Picked Players (${provider.pickedPlayers.length}/3)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (provider.pickedPlayers.isNotEmpty)
                  TextButton(
                    onPressed: provider.clearPickedPlayers,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.pickedPlayers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No players picked yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.pickedPlayers.length,
                itemBuilder: (context, index) {
                  final player = provider.pickedPlayers[index];
                  return _buildPlayerCard(player);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRatingColor(player.rating),
          child: Text(
            player.rating.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          player.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${player.position} • ${player.chemistryStyle}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${player.buyNowPrice}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'ID: ${player.transactionID}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Consumer<DsfutProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => PlayerDetailsDialog(
                            player: player,
                            console: provider.selectedConsole,
                          ),
                    );
                  },
                  tooltip: 'View Details',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 90) return Colors.purple;
    if (rating >= 85) return Colors.orange;
    if (rating >= 80) return Colors.yellow.shade700;
    if (rating >= 75) return Colors.green;
    return Colors.grey;
  }

  Widget _buildLogsCard(DsfutProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (provider.logs.isNotEmpty)
                  TextButton(
                    onPressed: provider.clearLogs,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  provider.logs.isEmpty
                      ? const Center(child: Text('No logs yet'))
                      : ListView.builder(
                        itemCount: provider.logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              provider.logs[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketOverviewCard(
    BuildContext context,
    DsfutProvider provider,
  ) {
    final stats = provider.playerStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Market Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AvailablePlayersScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarketStatColumn('Available', '${stats['total'] ?? 0}'),
                _buildMarketStatColumn('Special', '${stats['special'] ?? 0}'),
                _buildMarketStatColumn(
                  '85+ Rated',
                  '${stats['high_rated'] ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
