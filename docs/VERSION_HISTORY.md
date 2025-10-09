# Version History

## v0.1.0 - 2025-10-09

**Initial Project Setup**

### Added
- Project repository initialized with git
- Comprehensive `.gitignore` for Node.js, .NET, and Docker
- `PROJECT_SPEC.md` with complete technical specification covering:
  - Business problem and solution approach
  - Technical architecture (Ink React CLI + .NET 8 API)
  - NS API integration strategy
  - Split-flap terminal UI design
  - Timeline and milestones
- `VERSION_HISTORY.md` for semantic versioning tracking
- Project structure documentation

### Technical Details
- **Technology Stack:**
  - Frontend: Ink React 6.3.1 + React 19 + TypeScript
  - Backend: .NET 8 Web API
  - Cache: Redis 7
  - Deployment: Docker Compose
- **Architecture:** CLI application → .NET API proxy → NS API
- **Target Platform:** Terminal-based (macOS, Linux, Windows)

### Status
- **Phase:** Foundation / Project Setup
- **Next Steps:**
  - Create CLAUDE.md and README.md
  - Initialize CLI application structure
  - Initialize .NET API backend
  - Setup Docker configuration

---

## Roadmap

### v0.2.0 (Planned)
- Backend API implementation
  - NS API client with HttpClientFactory
  - Redis caching service
  - Controllers for stations and departures
  - Error handling middleware
  - Health checks

### v0.3.0 (Planned)
- CLI core implementation
  - Basic Ink React components
  - Station selector
  - Departure board display
  - API integration hooks

### v0.4.0 (Planned)
- UI polish and animations
  - Split-flap character animations
  - Box border styling
  - Color coding for delays/cancellations
  - Terminal responsiveness

### v0.5.0 (Planned)
- Integration testing and bug fixes
  - End-to-end testing
  - Performance optimization
  - Error handling improvements

### v1.0.0 (Planned)
- Production release
  - Complete documentation
  - npm package
  - Docker deployment guide
  - Public release

---

**Semantic Versioning:**
- **Major (X.0.0):** Breaking changes, major architectural changes
- **Minor (0.X.0):** New features, backward-compatible additions
- **Patch (0.0.X):** Bug fixes, minor improvements

**Changelog Guidelines:**
- **Added:** New features or functionality
- **Changed:** Changes to existing functionality
- **Deprecated:** Soon-to-be removed features
- **Removed:** Removed features
- **Fixed:** Bug fixes
- **Security:** Security improvements
