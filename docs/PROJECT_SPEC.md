# Project Specification: Amberglass - NS Train Departure Board CLI

## 1. Business Problem

**Problem Statement:**
Train travelers and transit enthusiasts need a clean, real-time way to monitor Nederlandse Spoorwegen (NS) train departures and arrivals from their desktop or terminal environment. Existing solutions require opening web browsers or mobile apps, which don't provide the immersive, always-on experience of classic train station departure boards.

**Target Users:**
- Transit enthusiasts who want classic train station aesthetics on their desktop
- Developers and tech workers who prefer terminal-based tools
- Home dashboard displaysusing repurposed devices (Surface Pro, Raspberry Pi, etc.)
- Anyone who wants ambient train departure information

**Pain Points:**
- No dedicated desktop/terminal application for NS train monitoring
- Web interfaces lack the nostalgic split-flap aesthetic
- Existing solutions don't auto-refresh or provide ambient display
- Mobile apps require active interaction rather than ambient awareness

## 2. Solution Approach

**Product Vision:**
A terminal-based CLI application that displays real-time NS train departures/arrivals with a classic mechanical split-flap display aesthetic, providing an immersive, always-on train station experience.

**Key Features:**
1. **Terminal-Based UI:** Rendered using Ink React for smooth, interactive CLI experience
2. **Split-Flap Aesthetic:** Classic mechanical departure board look using box-drawing characters
3. **Real-Time Updates:** Auto-refresh every 5-10 seconds with animated transitions
4. **Station Selection:** Keyboard navigation to select any NS station in the Netherlands
5. **Comprehensive Information:** Train number, destination, platform, departure time, delays, cancellations
6. **Ambient Display:** Fullscreen mode for always-on display on dedicated devices

**Technology Approach:**
- **Frontend:** Ink React (React for CLI) with TypeScript
- **Backend:** .NET 8 Web API as caching proxy for NS API
- **Caching:** Redis with 30-60 second TTL to minimize NS API calls
- **Deployment:** Docker for backend services, native CLI execution

## 3. Success Metrics

**Technical Metrics:**
- CLI response time < 100ms for cached data
- 95%+ cache hit rate (minimize NS API calls)
- Zero crashes during 24+ hour continuous operation
- Support terminals as small as 80x24 characters

**User Experience Metrics:**
- Smooth split-flap animations without flickering
- < 2 second station selection to first data display
- Clear visual indicators for delays, cancellations, platform changes
- Intuitive keyboard controls requiring no documentation

**Performance Metrics:**
- Backend API latency < 200ms
- Redis cache hit rate > 90%
- Backend uptime > 99.5%
- CLI memory usage < 100MB

## 4. Technical Architecture

### 4.1 System Architecture Overview

```
┌─────────────────────┐
│   Ink React CLI    │
│   (TypeScript)     │  ← User interacts via keyboard
│                    │
│  - Components      │
│  - Auto-refresh    │
│  - Split-flap UI   │
└──────────┬──────────┘
           │ HTTP
           │ (fetch API)
           ↓
┌─────────────────────┐
│   .NET 8 Web API   │
│   (Proxy Layer)    │
│                    │
│  - Controllers     │
│  - NS API Client   │
│  - Cache Service   │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
     ↓           ↓
┌─────────┐  ┌────────────┐
│  Redis  │  │   NS API   │
│ (Cache) │  │ (External) │
└─────────┘  └────────────┘
```

### 4.2 CLI Application Architecture (Ink React)

**Component Hierarchy:**
```
<App>                          # State container, station selection
  <StationSelector />          # Keyboard nav for station selection
  <DepartureBoard>             # Main board container
    <DepartureBoardHeader />   # Station name, time, last update
    {departures.map(dep =>
      <DepartureBoardRow       # Individual train row
        departure={dep}
      />
    )}
  </DepartureBoard>
</App>
```

**Key Hooks:**
- **useNSApi**: Fetch data from backend API
- **useAutoRefresh**: setInterval polling every 5-10 seconds
- **useKeyboardNav**: Handle arrow keys, Enter, Q (quit), R (refresh)

**Dependencies:**
- `ink` 6.3.1 - React for CLI
- `react` 19.1.0 - UI library
- `ink-spinner` - Loading indicators
- `chalk` - Color utilities
- `commander` - CLI argument parsing
- `date-fns` - Time formatting
- `node-fetch` - HTTP client

### 4.3 Backend API Architecture (.NET 8)

**Layers:**
```
Controllers → Services → External APIs
             ↓
          Cache (Redis)
```

**Controllers:**
- `StationsController`: GET /api/stations
- `DeparturesController`: GET /api/departures?station={code}
- `ArrivalsController`: GET /api/arrivals?station={code}
- `HealthController`: GET /health

**Services:**
- **NsApiClient**: HttpClient wrapper for NS API calls
- **RedisCacheService**: Cache-aside pattern implementation
- **ErrorHandlingMiddleware**: Global exception handling

**Caching Strategy:**
- Stations list: 60 second TTL (rarely changes)
- Departures: 45 second TTL (real-time but not too aggressive)
- Arrivals: 45 second TTL
- Cache key pattern: `ns:{endpoint}:{params}`

**NuGet Packages:**
- `StackExchange.Redis` - Redis client
- `Polly` - Resilience (retry, circuit breaker, timeout)
- `AspNetCore.HealthChecks.Redis` - Health monitoring

### 4.4 NS API Integration

**Base URL:** `https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2/`

**Authentication:** `Ocp-Apim-Subscription-Key` header

**Endpoints Used:**
- `GET /stations` - List all stations
- `GET /departures?station={code}` - Get departures for station

**Rate Limiting Mitigation:**
- Redis caching with 45-60s TTL
- Backend acts as proxy/buffer
- Polly retry policies with exponential backoff

### 4.5 Data Flow

1. **User Interaction:**
   - User launches CLI: `npx amberglass-cli --station AMS`
   - CLI renders station selector or directly displays station if provided

2. **Initial Data Load:**
   - CLI calls `GET http://localhost:5000/api/departures?station=AMS`
   - Backend checks Redis cache
   - Cache miss → Call NS API → Store in Redis (45s TTL) → Return to CLI
   - Cache hit → Return cached data immediately

3. **Auto-Refresh Cycle:**
   - Every 10 seconds (configurable):
     - CLI calls backend API
     - Backend returns cached data (most common) or fresh data if cache expired
     - CLI updates UI with split-flap animation for changed values

4. **User Actions:**
   - Arrow keys → Navigate station list
   - Enter → Select station and display departures
   - R → Manual refresh (bypass timer)
   - Q → Quit application

### 4.6 Terminal UI Design

**Split-Flap Aesthetic:**
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
║ 14:42  INT 234  BERLIN HBF                    1           -        ON TIME  ║
║ 14:45  IC 3456  UTRECHT CENTRAAL              4           -        ON TIME  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

**Visual Elements:**
- Box borders: Double-line characters (╔═╗║╚╝)
- Text color: Yellow/amber (classic split-flap)
- Uppercase text only (authentic aesthetic)
- Fixed-width columns for alignment
- Color coding:
  - Green: On time
  - Red: Delayed > 5 minutes
  - Yellow: Cancelled
  - Blue: Platform changed

**Split-Flap Animation:**
- Animate character changes by cycling through alphabet
- 50ms delay per character transition
- Only animate changed characters (performance)
- Skip animation if > 10 changes simultaneously

### 4.7 Deployment Architecture

**Development Environment:**
```
Terminal (CLI) → http://localhost:5000 → .NET API → Redis (localhost:6379)
                                        → NS API (HTTPS)
```

**Production Environment (Docker):**
```
Terminal (CLI) → http://localhost:5000 → Docker:
                                          - .NET API container
                                          - Redis container
                                        → NS API (HTTPS)
```

**Docker Compose Services:**
- `api`: .NET 8 Web API (port 5000)
- `redis`: Redis 7 (port 6379)

## 5. Timeline & Milestones

### Phase 1: Foundation (Week 1)
- **Milestone:** Project setup, git, documentation
- **Deliverables:**
  - Git repository initialized
  - PROJECT_SPEC.md, VERSION_HISTORY.md, CLAUDE.md, README.md
  - .gitignore configured
  - CLI project structure created
  - .NET API project structure created
  - Docker configuration files

### Phase 2: Backend Implementation (Week 1-2)
- **Milestone:** Functional .NET API with NS API integration
- **Deliverables:**
  - NsApiClient with HttpClientFactory
  - RedisCacheService with cache-aside pattern
  - Controllers (Stations, Departures, Health)
  - Error handling middleware
  - Polly resilience policies
  - Docker build working
  - Health checks functional

### Phase 3: CLI Core Implementation (Week 2-3)
- **Milestone:** Functional CLI with basic display
- **Deliverables:**
  - App, DepartureBoard, DepartureBoardRow components
  - useNSApi hook with fetch integration
  - useAutoRefresh hook with 10s polling
  - useKeyboardNav hook (arrow keys, Q, R)
  - Basic table layout with Box components
  - Station selector with keyboard navigation

### Phase 4: UI Polish & Animation (Week 3)
- **Milestone:** Split-flap aesthetic complete
- **Deliverables:**
  - Box border styling (double-line characters)
  - Color coding (delays, cancellations, platform changes)
  - Split-flap animation for text changes
  - Header with station name and last update timestamp
  - Responsive terminal sizing
  - Fullscreen mode

### Phase 5: Integration & Testing (Week 4)
- **Milestone:** End-to-end functional system
- **Deliverables:**
  - CLI ↔ API integration tested
  - Auto-refresh working smoothly
  - Error handling tested (API down, network issues)
  - Docker compose tested
  - Performance optimization (cache hit rates, animation smoothness)
  - Multiple station testing

### Phase 6: Documentation & Packaging (Week 4)
- **Milestone:** Production-ready release
- **Deliverables:**
  - Complete README with setup instructions
  - NS API key registration guide
  - Troubleshooting guide
  - CLI executable with shebang
  - npm package configuration
  - Docker deployment guide
  - v1.0.0 release

## 6. Technical Specifications

### 6.1 NS API Data Schema

**Station Object:**
```json
{
  "code": "AMS",
  "name": "Amsterdam Centraal",
  "country": "NL",
  "uicCode": "8400058"
}
```

**Departure Object:**
```json
{
  "cancelled": false,
  "company": "NS",
  "delay": 0,
  "departure_time": "2025-10-09T14:35:00+02:00",
  "destination_actual": "Den Haag Centraal",
  "destination_actual_codes": ["GVC"],
  "destination_planned": "Den Haag Centraal",
  "platform_actual": "5A",
  "platform_changed": false,
  "platform_planned": "5A",
  "service_number": "1234",
  "type": "Intercity",
  "type_code": "IC"
}
```

### 6.2 Backend API Endpoints

**GET /api/stations**
- Response: `Station[]`
- Cache TTL: 60 seconds
- No parameters

**GET /api/departures?station={code}**
- Query param: `station` (string, required)
- Response: `DeparturesResponse`
- Cache TTL: 45 seconds

**GET /api/health**
- Response: `{ status: "healthy", redis: "connected", nsApi: "available" }`
- No caching

### 6.3 CLI Configuration

**Environment Variables:**
- `API_URL`: Backend API base URL (default: `http://localhost:5000`)
- `REFRESH_INTERVAL`: Refresh interval in seconds (default: `10`)
- `ANIMATION_ENABLED`: Enable split-flap animation (default: `true`)

**Command-Line Arguments:**
```bash
amberglass-cli [options]

Options:
  -s, --station <code>      Station code (e.g., AMS for Amsterdam)
  -r, --refresh <seconds>   Refresh interval in seconds (default: 10)
  --no-animation            Disable split-flap animation
  -h, --help                Display help
  -v, --version             Display version
```

### 6.4 System Requirements

**CLI Requirements:**
- Node.js 20+
- Terminal with UTF-8 support
- Minimum 80x24 terminal size
- Recommended: 120x30 for optimal display

**Backend Requirements:**
- .NET 8 SDK (development)
- Docker & Docker Compose (deployment)
- Redis 7+
- NS API subscription key

## 7. Security & Privacy

**API Key Management:**
- NS API key stored in environment variables only
- Never committed to git (.env excluded)
- Docker secrets for production deployment

**Data Privacy:**
- No user data collected
- No tracking or analytics
- All data fetched from public NS API
- No persistent storage of user preferences

**Network Security:**
- HTTPS for NS API calls
- Local HTTP for CLI → Backend (trusted network)
- CORS restricted to localhost in development

## 8. Future Enhancements

**Version 1.1:**
- Support for arrivals board
- Multiple stations in split-screen view
- Train service details on demand

**Version 1.2:**
- Customizable color schemes
- Export departure data to CSV/JSON
- Notifications for specific trains/delays

**Version 2.0:**
- Support for international rail APIs (DB, SNCF, etc.)
- Web dashboard companion
- Historical delay tracking and statistics

## 9. References

- **NS API Portal:** https://apiportal.ns.nl/
- **Ink React Documentation:** https://github.com/vadimdemedes/ink
- **NS API Starters Guide:** https://apiportal.ns.nl/startersguide
- **Design Inspiration:** Classic Solari split-flap displays

## 10. Contact & Support

**Project Owner:** Ben Zatrok
**Project Type:** Personal revenue project (~/play/ directory)
**Development Standards:** See ~/.claude/CLAUDE.md for global standards

---

*This specification is a living document and will be updated as the project evolves.*
