import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/dsfut_api_service.dart';

class DsfutProvider extends ChangeNotifier {
  // State variables
  bool _isAutoPicking = false;
  bool _isLoading = false;
  List<Player> _pickedPlayers = [];
  List<DetailedPlayer> _availablePlayers = [];
  List<String> _logs = [];
  Prices? _currentPrices;
  Timer? _autoPickTimer;
  Timer? _pricesTimer;
  Timer? _playersTimer;

  // Configuration
  String _selectedConsole = 'ps';
  int _minPrice = 10000;
  int _maxPrice = 100000;
  int _pickInterval = 30; // seconds
  int _takeAfter = 3; // seconds

  // Account rotation tracking
  int _currentAccountIndex = 0;
  final List<String> _accounts = [
    'ps',
    'pc',
  ]; // Can be expanded for actual account rotation

  // Getters
  bool get isAutoPicking => _isAutoPicking;
  bool get isLoading => _isLoading;
  List<Player> get pickedPlayers => List.unmodifiable(_pickedPlayers);
  List<DetailedPlayer> get availablePlayers =>
      List.unmodifiable(_availablePlayers);
  List<String> get logs => List.unmodifiable(_logs);
  Prices? get currentPrices => _currentPrices;
  String get selectedConsole => _selectedConsole;
  int get minPrice => _minPrice;
  int get maxPrice => _maxPrice;
  int get pickInterval => _pickInterval;
  int get takeAfter => _takeAfter;

  DsfutProvider() {
    _loadPrices();
    _startPricesTimer();
    _loadAvailablePlayers();
    _startPlayersTimer();
  }

  @override
  void dispose() {
    _autoPickTimer?.cancel();
    _pricesTimer?.cancel();
    _playersTimer?.cancel();
    super.dispose();
  }

  // Configuration setters
  void setConsole(String console) {
    _selectedConsole = console;
    notifyListeners();
  }

  void setPriceRange(int min, int max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setPickInterval(int seconds) {
    _pickInterval = seconds;
    if (_isAutoPicking) {
      _stopAutoPicking();
      _startAutoPicking();
    }
    notifyListeners();
  }

  void setTakeAfter(int seconds) {
    _takeAfter = seconds;
    notifyListeners();
  }

  // Add log entry
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logs.insert(0, '[$timestamp] $message');
    if (_logs.length > 100) {
      _logs.removeRange(100, _logs.length);
    }
    notifyListeners();
  }

  // Load current prices
  Future<void> _loadPrices() async {
    try {
      final prices = await DsfutApiService.getPrices();
      if (prices != null) {
        _currentPrices = prices;
        _addLog(
          'Prices updated: Console: \$${prices.console100k}, PC: \$${prices.pc100k}',
        );
        notifyListeners();
      }
    } catch (e) {
      _addLog('Failed to load prices: $e');
    }
  }

  // Start prices timer (update every 5 minutes)
  void _startPricesTimer() {
    _pricesTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadPrices();
    });
  }

  // Get next account for rotation
  String _getNextAccount() {
    final account = _selectedConsole; // For now, using the selected console
    _currentAccountIndex = (_currentAccountIndex + 1) % _accounts.length;
    return account;
  }

  // Pick a single player
  Future<void> pickPlayer() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final console = _getNextAccount();
      _addLog('Attempting to pick player from $console...');

      final response = await DsfutApiService.popPlayer(
        console: console,
        minBuy: _minPrice,
        maxBuy: _maxPrice,
        takeAfter: _takeAfter,
      );

      if (response.isSuccess && response.player != null) {
        _pickedPlayers.insert(0, response.player!);
        _addLog(
          '✅ ${response.message}: ${response.player!.name} (${response.player!.rating}) - \$${response.player!.buyNowPrice}',
        );

        // Start monitoring this player's transaction
        _monitorTransaction(response.player!);
      } else {
        _addLog('❌ ${response.error}: ${response.message}');
      }
    } catch (e) {
      _addLog('❌ Error picking player: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Monitor transaction status
  void _monitorTransaction(Player player) {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (timer.tick > 18) {
        // Stop after 3 minutes (18 * 10 seconds)
        timer.cancel();
        _addLog('⏰ Monitoring stopped for ${player.name} (timeout)');
        return;
      }

      final status = await DsfutApiService.getTransactionStatus(
        player.transactionID,
      );
      if (status != null) {
        if (status.isSuccessful) {
          _addLog(
            '✅ Transaction completed for ${player.name}: \$${status.amount}',
          );
          timer.cancel();
        } else if (status.error != null) {
          _addLog('❌ Transaction failed for ${player.name}: ${status.error}');
          timer.cancel();
        }
      }
    });
  }

  // Start automatic picking
  void startAutoPicking() {
    if (_isAutoPicking) return;

    _isAutoPicking = true;
    _addLog('🚀 Auto-picking started (interval: ${_pickInterval}s)');
    notifyListeners();

    _startAutoPicking();
  }

  void _startAutoPicking() {
    _autoPickTimer = Timer.periodic(Duration(seconds: _pickInterval), (_) {
      if (_pickedPlayers.length < 3) {
        // API limit of 3 active players
        pickPlayer();
      } else {
        _addLog('⚠️ Skipping pick - maximum 3 active players reached');
      }
    });
  }

  // Stop automatic picking
  void stopAutoPicking() {
    if (!_isAutoPicking) return;

    _stopAutoPicking();
    _isAutoPicking = false;
    _addLog('⏹️ Auto-picking stopped');
    notifyListeners();
  }

  void _stopAutoPicking() {
    _autoPickTimer?.cancel();
    _autoPickTimer = null;
  }

  // Clear picked players
  void clearPickedPlayers() {
    _pickedPlayers.clear();
    _addLog('🗑️ Picked players cleared');
    notifyListeners();
  }

  // Clear logs
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  // Manual refresh prices
  Future<void> refreshPrices() async {
    await _loadPrices();
  }

  // Load available players from the detailed API
  Future<void> _loadAvailablePlayers() async {
    try {
      final players = await DsfutApiService.getAllPlayers();
      if (players != null) {
        _availablePlayers = players;
        _addLog(
          '📋 Available players updated: ${players.length} players found',
        );
        notifyListeners();
      }
    } catch (e) {
      _addLog('Failed to load available players: $e');
    }
  }

  // Start players timer (update every 30 seconds)
  void _startPlayersTimer() {
    _playersTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadAvailablePlayers();
    });
  }

  // Manual refresh available players
  Future<void> refreshAvailablePlayers() async {
    await _loadAvailablePlayers();
  }

  // Get filtered available players based on current settings
  List<DetailedPlayer> get filteredAvailablePlayers {
    return _availablePlayers.where((player) {
      // Filter by console
      if (player.console != _selectedConsole &&
          player.console != '${_selectedConsole}5') {
        return false;
      }

      // Filter by price range
      if (player.price < _minPrice || player.price > _maxPrice) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get player statistics
  Map<String, int> get playerStats {
    final filtered = filteredAvailablePlayers;
    final stats = <String, int>{};

    stats['total'] = filtered.length;
    stats['special'] = filtered.where((p) => p.isSpecial).length;
    stats['high_rated'] = filtered.where((p) => p.rating >= 85).length;

    // Price ranges
    stats['under_50k'] = filtered.where((p) => p.price < 50000).length;
    stats['50k_100k'] =
        filtered.where((p) => p.price >= 50000 && p.price < 100000).length;
    stats['over_100k'] = filtered.where((p) => p.price >= 100000).length;

    return stats;
  }
}
