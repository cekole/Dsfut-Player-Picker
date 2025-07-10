# DSFUT Automate

A Flutter application for automated FIFA Ultimate Team coin trading using the DSFUT API.

## Features

- ✅ Automatic player picking with configurable intervals
- 🔄 Account rotation to prevent bans
- 📊 Real-time market analysis and player statistics
- 💰 Live price tracking across all platforms
- 📱 Player details with images, attributes, and market data
- 🎯 Smart filtering by console, price range, and player criteria
- 📈 Transaction monitoring and status tracking

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd dsfut_automate
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Credentials

**IMPORTANT**: You need to set up your DSFUT API credentials before running the app.

1. Copy the template configuration file:
   ```bash
   cp lib/config/secrets.dart.template lib/config/secrets.dart
   ```

2. Edit `lib/config/secrets.dart` and replace the placeholder values with your actual DSFUT credentials:
   ```dart
   static const String partnerId = 'YOUR_ACTUAL_PARTNER_ID';
   static const String secretKey = 'YOUR_ACTUAL_SECRET_KEY';
   ```

3. Get your credentials from [DSFUT](https://dsfut.net/) if you don't have them yet.

### 4. Run the Application
```bash
flutter run
```

## Security Notes

- ⚠️ **Never commit your actual API credentials to version control**
- ✅ The `secrets.dart` file is automatically ignored by Git
- ✅ Use the template file for sharing the project structure
- ✅ Each developer should create their own `secrets.dart` file locally

## Usage

1. **Configure Settings**: Set your preferred console, price range, and picking intervals
2. **Manual Picking**: Use "Pick Player" to manually grab players from the market
3. **Auto Mode**: Enable automatic picking for hands-free operation
4. **Market Analysis**: Browse available players with detailed information
5. **Player Details**: Tap the info button on picked players to see comprehensive details

## API Endpoints Used

- `GET /api/{year}/{console}/{partnerId}/{timestamp}/{signature}` - Pick player
- `GET /api/{year}/prices` - Get current prices
- `GET /api/{year}/transaction/status/{transactionId}` - Check transaction status
- `GET /api/json/players` - List available players
- `GET /api/{console}/getPlayer/{partnerId}/{resourceId}` - Get player details

## Requirements

- Flutter 3.7.0 or higher
- Valid DSFUT API credentials
- Internet connection

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make sure not to commit any credentials
4. Submit a pull request

## License

This project is for educational purposes only. Please respect the DSFUT API terms of service.
