import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/dsfut_api_service.dart';

class PlayerDetailsDialog extends StatefulWidget {
  final Player player;
  final String console;

  const PlayerDetailsDialog({
    super.key,
    required this.player,
    required this.console,
  });

  @override
  State<PlayerDetailsDialog> createState() => _PlayerDetailsDialogState();
}

class _PlayerDetailsDialogState extends State<PlayerDetailsDialog> {
  DetailedPlayerInfo? _detailedInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerDetails();
  }

  Future<void> _loadPlayerDetails() async {
    try {
      final console = widget.console == 'ps' ? 'ps5' : widget.console;
      final details = await DsfutApiService.getPlayerById(
        console,
        widget.player.resourceID,
      );
      if (mounted) {
        setState(() {
          _detailedInfo = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Player Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _detailedInfo != null
                      ? _buildPlayerDetails()
                      : _buildBasicPlayerInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerDetails() {
    final details = _detailedInfo!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Image and Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Image
              Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getRatingColor(details.rating),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child:
                      details.image != null
                          ? Image.network(
                            details.image!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildPlaceholderImage(),
                          )
                          : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(width: 16),
              // Basic Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.cardName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      details.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          '${details.rating}',
                          _getRatingColor(details.rating),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(details.position, Colors.blue),
                        const SizedBox(width: 8),
                        if (details.rareName != null)
                          _buildInfoChip(details.rareName!, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (details.imageNation != null) ...[
                          Image.network(
                            details.imageNation!,
                            width: 24,
                            height: 16,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.flag, size: 16),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (details.imageClub != null) ...[
                          Image.network(
                            details.imageClub!,
                            width: 24,
                            height: 24,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.sports_soccer, size: 16),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Player Attributes
          Text(
            'Player Attributes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttributeColumn('PAC', details.attr1),
                _buildAttributeColumn('SHO', details.attr2),
                _buildAttributeColumn('PAS', details.attr3),
                _buildAttributeColumn('DRI', details.attr4),
                _buildAttributeColumn('DEF', details.attr5),
                _buildAttributeColumn('PHY', details.attr6),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Market Prices
          Text('Market Prices', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildPricesSection(details),
          const SizedBox(height: 24),

          // Transaction Info
          Text(
            'Transaction Info',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildTransactionInfo(),
        ],
      ),
    );
  }

  Widget _buildBasicPlayerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.player.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip(
              '${widget.player.rating}',
              _getRatingColor(widget.player.rating),
            ),
            const SizedBox(width: 8),
            _buildInfoChip(widget.player.position, Colors.blue),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionInfo(),
        const SizedBox(height: 16),
        const Text(
          'Detailed player information could not be loaded.',
          style: TextStyle(color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, size: 60),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getAttributeColor(value),
          ),
        ),
      ],
    );
  }

  Widget _buildPricesSection(DetailedPlayerInfo details) {
    return Column(
      children: [
        _buildPriceRow(
          'PlayStation',
          details.psLowestBin,
          details.psMinPrice,
          details.psMaxPrice,
        ),
        _buildPriceRow(
          'PlayStation 5',
          details.ps5LowestBin,
          details.ps5MinPrice,
          details.ps5MaxPrice,
        ),
        _buildPriceRow(
          'Xbox',
          details.xbLowestBin,
          details.xbMinPrice,
          details.xbMaxPrice,
        ),
        _buildPriceRow(
          'Xbox Series X|S',
          details.xbsxLowestBin,
          details.xbsxMinPrice,
          details.xbsxMaxPrice,
        ),
        _buildPriceRow(
          'PC',
          details.pcLowestBin,
          details.pcMinPrice,
          details.pcMaxPrice,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String platform,
    int currentPrice,
    int minPrice,
    int maxPrice,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(platform, style: const TextStyle(fontWeight: FontWeight.w500)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_formatPrice(currentPrice)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${_formatPrice(minPrice)} - \$${_formatPrice(maxPrice)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Trade ID', widget.player.tradeID.toString()),
          _buildInfoRow(
            'Transaction ID',
            widget.player.transactionID.toString(),
          ),
          _buildInfoRow('Buy Now Price', '\$${widget.player.buyNowPrice}'),
          _buildInfoRow('Start Price', '\$${widget.player.startPrice}'),
          _buildInfoRow('Contracts', widget.player.contracts.toString()),
          _buildInfoRow('Owners', widget.player.owners.toString()),
          _buildInfoRow('Chemistry Style', widget.player.chemistryStyle),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
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

  Color _getAttributeColor(int attribute) {
    if (attribute >= 90) return Colors.green;
    if (attribute >= 80) return Colors.orange;
    if (attribute >= 70) return Colors.amber;
    return Colors.grey;
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }
}
