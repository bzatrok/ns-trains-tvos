# Amberglass CLI - Claude Development Guidelines

This document contains project-specific guidelines for Claude Code agents working on the Amberglass NS Train Departure Board CLI project.

## Project Overview

**Name:** Amberglass CLI
**Type:** Personal revenue project (~/play/ directory)
**Purpose:** Terminal-based NS train departure board with classic split-flap aesthetic
**Tech Stack:**
- CLI: Ink React 6.3.1 + React 19 + TypeScript
- Backend: .NET 8 Web API
- Cache: Redis 7
- Deployment: Docker Compose

## Architecture Quick Reference

```
Terminal (Ink CLI) → HTTP → .NET API → Redis Cache
                                     → NS API
```

**Key Directories:**
- `cli/` - Ink React CLI application (TypeScript)
- `api/` - .NET 8 Web API backend
- `docs/` - Project documentation
- `docker/` - Docker configuration
- `_sample/` - Reference code (gitignored, DO NOT modify)

## Development Workflow

### Quick Test Commands

**CLI Development:**
```bash
cd cli/
yarn install          # Install dependencies
yarn dev             # Development mode with watch
yarn build           # Build TypeScript to JavaScript
yarn start           # Run built CLI
yarn lint            # ESLint
```

**Backend Development:**
```bash
cd api/
dotnet restore       # Restore dependencies
dotnet build         # Build project
dotnet run           # Run API (port 5000)
dotnet test          # Run tests
```

**Docker:**
```bash
cd docker/
docker-compose up -d           # Start backend + Redis
docker-compose logs -f api     # Follow API logs
docker-compose down            # Stop services
```

### Automated Behaviors

**When editing CLI components (cli/src/components/):**
1. Always check TypeScript types
2. Run `yarn lint --fix` to auto-fix style issues
3. Test locally with `yarn dev`

**When editing backend code (api/):**
1. Run `dotnet build` to check for compilation errors
2. Verify health check still works: `curl http://localhost:5000/health`
3. Test API endpoints with curl or Postman

**When changing dependencies:**
- CLI: Update `cli/package.json`, run `yarn install`
- API: Add NuGet package, run `dotnet restore`
- Always commit lockfiles (yarn.lock, *.csproj)

**Before committing:**
1. Run linters (yarn lint for CLI, dotnet format for API)
2. Ensure no build errors
3. Update VERSION_HISTORY.md if functionality changed
4. Test the full flow: CLI → API → NS API

## Code Style Guidelines

### Ink React / TypeScript

**Component Structure:**
```typescript
import React from 'react';
import { Box, Text, useInput } from 'ink';

interface Props {
  // Props here
}

export const ComponentName: React.FC<Props> = ({ prop }) => {
  // Hooks at top
  const [state, setState] = React.useState();

  useInput((input, key) => {
    // Input handling
  });

  // Render
  return (
    <Box>
      <Text>Content</Text>
    </Box>
  );
};
```

**Naming Conventions:**
- Components: PascalCase (e.g., `DepartureBoard.tsx`)
- Hooks: camelCase with 'use' prefix (e.g., `useNSApi.ts`)
- Types: PascalCase (e.g., `DepartureData`)
- Constants: UPPER_SNAKE_CASE

**Import Order:**
1. React imports
2. Ink imports
3. Third-party libraries
4. Local hooks
5. Local types
6. Local utilities

### .NET C#

**Controller Pattern:**
```csharp
[ApiController]
[Route("api/[controller]")]
public class DeparturesController : ControllerBase
{
    private readonly INsApiClient _client;
    private readonly ILogger<DeparturesController> _logger;

    public DeparturesController(INsApiClient client, ILogger<DeparturesController> logger)
    {
        _client = client;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<DeparturesResponse>> GetDepartures(
        [FromQuery] string station,
        CancellationToken ct = default)
    {
        // Implementation
    }
}
```

**Naming Conventions:**
- Classes: PascalCase
- Methods: PascalCase
- Private fields: _camelCase with underscore prefix
- Interfaces: IPascalCase (I prefix)

## Testing Standards

### CLI Testing
- Manual testing in terminal (80x24 minimum)
- Test keyboard navigation (arrows, Enter, Q, R)
- Verify auto-refresh works correctly
- Test with different stations

### Backend Testing
- Health check: `curl http://localhost:5000/health`
- Stations: `curl http://localhost:5000/api/stations`
- Departures: `curl "http://localhost:5000/api/departures?station=AMS"`
- Verify Redis caching (check logs for cache hits/misses)

### Integration Testing
1. Start backend: `docker-compose up -d`
2. Start CLI: `cd cli && yarn start --station AMS`
3. Verify data displays correctly
4. Wait 10 seconds, verify auto-refresh
5. Press R to force refresh
6. Press Q to quit gracefully

## Common Tasks

### Add New CLI Component
1. Create file in `cli/src/components/ComponentName.tsx`
2. Import React, Ink components
3. Define TypeScript interface for props
4. Implement component with proper typing
5. Export component
6. Import in parent component

### Add New API Endpoint
1. Create controller in `api/Controllers/NameController.cs`
2. Inject required services (INsApiClient, ICacheService)
3. Implement endpoint with proper HTTP method attribute
4. Add XML documentation comments
5. Update Swagger/OpenAPI docs
6. Test with curl

### Update NS API Integration
1. Modify `api/Services/NsApiClient.cs`
2. Update models in `api/Models/` if schema changed
3. Update cache keys and TTL in service methods
4. Test with real NS API (requires valid API key)
5. Verify error handling for API failures

### Change Auto-Refresh Interval
1. Update default in `cli/src/hooks/useAutoRefresh.ts`
2. Update CLI argument parser in `cli/src/index.ts`
3. Update documentation in README.md
4. Update PROJECT_SPEC.md if significant change

## Environment Configuration

### CLI Environment Variables
```bash
API_URL=http://localhost:5000          # Backend API URL
REFRESH_INTERVAL=10                    # Refresh interval in seconds
ANIMATION_ENABLED=true                 # Enable split-flap animation
```

### Backend Environment Variables
```bash
NsApi__SubscriptionKey=your-key-here   # NS API key (REQUIRED)
NsApi__BaseUrl=https://...             # NS API base URL
NsApi__CacheDurationSeconds=45         # Cache TTL
Redis__ConnectionString=localhost:6379  # Redis connection
```

### Docker Environment
Set in `docker/.env`:
```bash
NS_API_KEY=your-key-here
REDIS_PASSWORD=optional-password
```

## Troubleshooting Guide

### CLI won't start
- Check Node.js version (requires 20+)
- Run `yarn install` to reinstall dependencies
- Check `API_URL` environment variable
- Verify backend is running (`curl http://localhost:5000/health`)

### Backend API errors
- Check NS API key is set (`NsApi__SubscriptionKey`)
- Verify Redis is running (`docker-compose ps`)
- Check logs (`docker-compose logs -f api`)
- Test NS API directly (curl with your key)

### No data displaying in CLI
- Backend not running or not accessible
- NS API key invalid or expired
- Station code invalid (use 3-letter code like "AMS")
- Check network connectivity

### Split-flap animation issues
- Terminal doesn't support UTF-8 box-drawing characters
- Terminal too small (minimum 80x24)
- Set `ANIMATION_ENABLED=false` to disable

### Cache not working
- Redis not running (`docker-compose ps`)
- Redis connection string incorrect
- Check cache keys in logs
- Verify TTL settings in backend config

## Command Allowlist

Claude agents are permitted to use these commands for this project:

### Development
```bash
# Node/Yarn (CLI)
yarn install
yarn dev
yarn build
yarn start
yarn lint
yarn lint:fix

# .NET (API)
dotnet restore
dotnet build
dotnet run
dotnet test
dotnet format
dotnet add package
dotnet list package

# Docker
docker-compose up -d
docker-compose down
docker-compose logs
docker-compose ps
docker build
docker ps
```

### Testing
```bash
# CLI testing
node cli/build/index.js --station AMS

# API testing
curl http://localhost:5000/health
curl http://localhost:5000/api/stations
curl "http://localhost:5000/api/departures?station=AMS"

# Redis testing
docker-compose exec redis redis-cli
```

### Git
```bash
git status
git add .
git commit -m "message"
git push
git log --oneline
git diff
```

## File Access Permissions

**Always Read First:**
- CLI components before editing
- Backend controllers/services before modifying
- Configuration files before changing settings

**Edit Freely:**
- Source code in `cli/src/` and `api/`
- Configuration files (package.json, appsettings.json)
- Documentation in `docs/`

**Never Edit:**
- `_sample/` folder (reference code only, gitignored)
- Lockfiles without running install commands
- Generated files in `build/`, `bin/`, `obj/`

## Known Issues & Solutions

### Issue: NS API rate limiting
**Solution:** Backend caching with Redis (45s TTL) prevents excessive calls

### Issue: Terminal flickering during updates
**Solution:** Use React.memo() on DepartureBoardRow, limit re-renders

### Issue: Docker port conflicts
**Solution:** Change ports in docker-compose.yml if 5000 or 6379 occupied

### Issue: Split-flap animation too slow
**Solution:** Reduce character transition delay in SplitFlapText component

## Architecture Decisions

### Why Ink React for CLI?
- React component model familiar and reusable
- Rich ecosystem (ink-spinner, etc.)
- Better than raw Node.js + blessed
- TypeScript support out of the box

### Why .NET for Backend?
- Fast, efficient API performance
- Excellent Redis support (StackExchange.Redis)
- Strong typing and async/await patterns
- Good HTTP client with Polly resilience

### Why Redis for Caching?
- Fast in-memory cache (sub-millisecond)
- TTL support built-in
- Can scale to multiple API instances
- Simple key-value model fits use case

### Why Docker for Backend Only?
- CLI needs to run natively for terminal access
- Backend + Redis containerized for easy deployment
- Developers can run backend without .NET SDK
- Production: CLI on device, backend in Docker

## Version Management

**When to bump version:**
- Patch (0.0.X): Bug fixes, no new features
- Minor (0.X.0): New features, backward compatible
- Major (X.0.0): Breaking changes, architecture changes

**Update these files:**
1. `docs/VERSION_HISTORY.md` - Add changelog entry
2. `cli/package.json` - Update version field
3. `api/[ProjectName].csproj` - Update Version property
4. Git tag: `git tag v1.0.0`

## Deployment Checklist

**Pre-deployment:**
- [ ] All tests passing
- [ ] No linter warnings
- [ ] Documentation updated
- [ ] VERSION_HISTORY.md updated
- [ ] Environment variables documented
- [ ] Docker build succeeds

**Deployment:**
- [ ] Build CLI: `yarn build`
- [ ] Build API Docker image
- [ ] Push to container registry
- [ ] Deploy with docker-compose
- [ ] Verify health check
- [ ] Test CLI connection to backend

**Post-deployment:**
- [ ] Monitor logs for errors
- [ ] Check cache hit rates
- [ ] Verify NS API calls within limits
- [ ] Test from user perspective

---

**For questions or issues:**
Refer to PROJECT_SPEC.md for technical architecture details.
Refer to README.md for user-facing setup instructions.
Refer to global ~/.claude/CLAUDE.md for Ben's development standards.
