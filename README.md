# Amberglass CLI - NS Train Departure Board

A terminal-based application that displays real-time Nederlandse Spoorwegen (NS) train departures with a classic mechanical split-flap display aesthetic.

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    AMSTERDAM CENTRAAL - DEPARTURES                          ║
║                         Last Update: 14:32:15                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ TIME   TRAIN    DESTINATION                   PLATFORM    DELAY    STATUS   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 14:35  IC 1234  DEN HAAG CENTRAAL             5A          +2 MIN   DELAYED  ║
║ 14:37  SPR 567  SCHIPHOL AIRPORT              3           -        ON TIME  ║
║ 14:40  IC 8901  ROTTERDAM CENTRAAL            2B          +5 MIN   DELAYED  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Features

- **Real-Time Updates:** Auto-refresh every 5-10 seconds
- **Classic Aesthetic:** Split-flap mechanical board look using box-drawing characters
- **Interactive:** Keyboard navigation for station selection
- **Comprehensive:** Shows train number, destination, platform, delays, cancellations
- **Terminal-Native:** Runs directly in your terminal, no browser needed
- **Lightweight:** Minimal resource usage, perfect for always-on displays

## Architecture

Amberglass consists of two components:

1. **CLI Application** (Ink React + TypeScript) - Terminal UI
2. **Backend API** (.NET 8) - Caching proxy for NS API

```
Terminal (Ink CLI) → HTTP → .NET API → Redis Cache
                                     → NS API
```

## Prerequisites

### For CLI Usage
- Node.js 20+ (LTS recommended)
- Terminal with UTF-8 support
- Minimum 80x24 terminal size (120x30 recommended)

### For Backend Development
- .NET 8 SDK
- Docker & Docker Compose (for Redis)
- NS API subscription key ([Get one here](https://apiportal.ns.nl/))

## Quick Start

### 1. Get NS API Key

1. Visit [NS API Portal](https://apiportal.ns.nl/)
2. Create an account
3. Subscribe to the "Ns-App" product
4. Copy your subscription key

### 2. Start Backend Services

```bash
# Clone repository
git clone <repository-url>
cd Amberglass.CLI

# Set NS API key
cd docker
cp .env.example .env
# Edit .env and add your NS_API_KEY

# Start backend + Redis
docker-compose up -d

# Verify backend is running
curl http://localhost:5000/health
```

### 3. Run CLI Application

```bash
cd cli

# Install dependencies
yarn install

# Run in development mode
yarn dev

# Or build and run
yarn build
yarn start --station AMS
```

## CLI Usage

### Basic Usage

```bash
# Start with station selection
npx amberglass-cli

# Start with specific station
npx amberglass-cli --station AMS

# Custom refresh interval
npx amberglass-cli --station RTD --refresh 15

# Disable animations
npx amberglass-cli --station UT --no-animation
```

### Keyboard Controls

- **Arrow Keys**: Navigate station list
- **Enter**: Select station
- **R**: Manual refresh
- **Q**: Quit application
- **Ctrl+C**: Force quit

### Command-Line Options

```
Options:
  -s, --station <code>      Station code (e.g., AMS for Amsterdam Centraal)
  -r, --refresh <seconds>   Refresh interval in seconds (default: 10)
  --no-animation            Disable split-flap animation
  -h, --help                Display help
  -v, --version             Display version
```

### Common Station Codes

- **AMS**: Amsterdam Centraal
- **RTD**: Rotterdam Centraal
- **UT**: Utrecht Centraal
- **EHV**: Eindhoven Centraal
- **GVC**: Den Haag Centraal
- **ASD**: Amsterdam Sloterdijk
- **ASDZ**: Amsterdam Zuid
- **ASDB**: Amsterdam Bijlmer ArenA

[Full station list](https://www.ns.nl/stationsinformatie)

## Installation

### Global Installation (npm)

```bash
npm install -g amberglass-cli
amberglass-cli --station AMS
```

### Local Development

```bash
# CLI
cd cli
yarn install
yarn dev

# Backend
cd api
dotnet restore
dotnet run
```

## Configuration

### CLI Environment Variables

Create `cli/.env`:

```bash
API_URL=http://localhost:5000
REFRESH_INTERVAL=10
ANIMATION_ENABLED=true
```

### Backend Configuration

Edit `api/appsettings.json` or set environment variables:

```json
{
  "NsApi": {
    "BaseUrl": "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2/",
    "SubscriptionKey": "",  // Set via env var: NsApi__SubscriptionKey
    "CacheDurationSeconds": 45,
    "TimeoutSeconds": 10
  },
  "Redis": {
    "ConnectionString": "localhost:6379"
  }
}
```

## Project Structure

```
Amberglass.CLI/
├── cli/                   # Ink React CLI Application
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom hooks
│   │   ├── types/         # TypeScript types
│   │   └── utils/         # Utilities
│   ├── package.json
│   └── tsconfig.json
├── api/                   # .NET 8 Web API
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   └── Program.cs
├── docker/
│   ├── docker-compose.yml
│   └── .env.example
├── docs/
│   ├── PROJECT_SPEC.md
│   ├── VERSION_HISTORY.md
│   └── CLAUDE.md
└── README.md
```

## Development

### Run Backend Locally

```bash
cd api
dotnet restore
dotnet run
# API runs on http://localhost:5000
```

### Run CLI in Development

```bash
cd cli
yarn install
yarn dev
```

### Run Tests

```bash
# CLI linting
cd cli
yarn lint

# Backend tests
cd api
dotnet test
```

### Docker Development

```bash
cd docker

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down
```

## Troubleshooting

### Backend won't start

**Problem:** API returns 500 errors
**Solution:**
- Check NS API key is set correctly
- Verify Redis is running: `docker-compose ps`
- Check logs: `docker-compose logs -f api`

### CLI shows no data

**Problem:** CLI displays empty board
**Solution:**
- Ensure backend is running: `curl http://localhost:5000/health`
- Check API_URL environment variable
- Verify station code is correct (3-letter code)

### Split-flap animation issues

**Problem:** Characters don't display correctly
**Solution:**
- Ensure terminal supports UTF-8
- Try a different terminal emulator
- Disable animations: `--no-animation`

### Rate limiting errors

**Problem:** "429 Too Many Requests" from NS API
**Solution:**
- Backend caches responses (45s TTL)
- Increase refresh interval: `--refresh 30`
- Check Redis is caching properly

## API Endpoints

Backend exposes these endpoints:

### GET /health
Health check endpoint

**Response:**
```json
{
  "status": "healthy",
  "redis": "connected",
  "nsApi": "available"
}
```

### GET /api/stations
List all NS stations

**Response:**
```json
[
  {
    "code": "AMS",
    "name": "Amsterdam Centraal",
    "country": "NL"
  }
]
```

### GET /api/departures?station={code}
Get departures for station

**Parameters:**
- `station` (required): 3-letter station code

**Response:**
```json
{
  "departures": [
    {
      "cancelled": false,
      "company": "NS",
      "delay": 0,
      "departureTime": "2025-10-09T14:35:00+02:00",
      "destination": "Den Haag Centraal",
      "platform": "5A",
      "serviceNumber": "1234",
      "type": "Intercity"
    }
  ]
}
```

## Contributing

This is a personal project, but contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

See [VERSION_HISTORY.md](docs/VERSION_HISTORY.md) for planned features.

**Upcoming:**
- v0.2.0: Backend API implementation
- v0.3.0: CLI core functionality
- v0.4.0: Split-flap animations and polish
- v1.0.0: Public release

## License

MIT License - see LICENSE file for details

## Acknowledgments

- **NS (Nederlandse Spoorwegen)** for providing the public API
- **Ink** by Vadim Demedes for the excellent React CLI framework
- **Classic Solari boards** for design inspiration

## Links

- [NS API Portal](https://apiportal.ns.nl/)
- [Ink Documentation](https://github.com/vadimdemedes/ink)
- [Project Specification](docs/PROJECT_SPEC.md)
- [Development Guidelines](docs/CLAUDE.md)

---

**Made with ❤️ for train enthusiasts and terminal lovers**
