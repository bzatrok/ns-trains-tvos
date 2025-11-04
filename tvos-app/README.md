# NS Trains tvOS - Proof of Concept

Apple TV app for displaying NS (Nederlandse Spoorwegen) train departure information.

## Overview

This is a proof-of-concept tvOS application built with Expo and React Native tvOS. It demonstrates NS-branded styling and serves as the foundation for building a full-featured train departure board for Apple TV.

## Features (POC)

- ✅ NS brand colors (Blue #003082, Yellow #FFC917)
- ✅ tvOS-optimized layout and typography
- ✅ Static welcome screen
- 🚧 Station selector (coming next)
- 🚧 Live departure board (coming next)
- 🚧 Train radar map (coming next)

## Requirements

- **Node.js** 20.19.0 or higher
- **Xcode 16+** with tvOS SDK
- **Apple TV** (physical device or simulator)
- **Apple Developer account** (free tier works for development)

## Installation

```bash
# Install dependencies
yarn install --ignore-engines

# Note: --ignore-engines flag is needed due to Node version requirements
```

## Running the App

### Option 1: tvOS Simulator

```bash
# Start the development server and run in Apple TV simulator
yarn tvos:simulator
```

This will:
1. Prebuild the iOS project with tvOS support
2. Launch Apple TV Simulator (requires Xcode)
3. Install and run the app
4. Start Metro bundler

### Option 2: Physical Apple TV

```bash
# Connect your Apple TV via USB-C or ensure it's on the same network
yarn tvos
```

This will:
1. Prebuild the iOS project
2. Show available devices (select your Apple TV)
3. Install and run the app on your TV

### Option 3: Development Mode

```bash
# Just start the Metro bundler
yarn start

# Then press 'i' to run on iOS simulator
# Or manually build via Xcode for more control
```

## Deployment Instructions

### First-Time Setup

1. **Enable Developer Mode on Apple TV**
   - Settings → Remotes and Devices → Remote App and Devices
   - Enable "Developer Mode"

2. **Connect Apple TV**
   - USB-C: Connect directly to Mac
   - Network: Ensure TV is on same Wi-Fi as Mac
   - Pair via Xcode: Window → Devices and Simulators

3. **Build Configuration**
   ```bash
   # Generate native iOS project
   yarn prebuild

   # Open in Xcode to configure signing
   open ios/*.xcworkspace
   ```

4. **Configure Signing in Xcode**
   - Select project in navigator
   - Select tvOS target
   - Signing & Capabilities tab
   - Team: Select your Apple Developer account
   - Bundle Identifier: `com.amberglass.nstrains.tvos`

5. **Deploy**
   ```bash
   yarn tvos
   ```

### Troubleshooting

**"No devices found"**
- Verify Apple TV is connected (USB or network)
- Check Settings → Remotes and Devices → Remote App and Devices
- Restart Apple TV
- Try: Xcode → Window → Devices and Simulators

**"Code signing error"**
- Open `ios/*.xcworkspace` in Xcode
- Configure signing with your Apple ID
- Ensure bundle ID matches `com.amberglass.nstrains.tvos`

**"Metro bundler connection failed"**
- Ensure Apple TV and Mac are on same network
- Restart Metro: `yarn start --reset-cache`
- Check firewall settings (allow incoming connections)

**"Node version mismatch"**
- Use `--ignore-engines` flag with yarn commands
- Or upgrade Node to 20.19.4+

## Project Structure

```
tvos-app/
├── App.js                 # Main app component (POC welcome screen)
├── app.json              # Expo configuration with tvOS plugin
├── package.json          # Dependencies and scripts
├── assets/               # Images and icons
└── README.md            # This file
```

## Next Steps

After verifying the POC works on your Apple TV:

1. **Port NS API Integration**
   - Copy `useNSApi.ts` hook from CLI project
   - Add environment configuration for API key

2. **Build Station Selector**
   - Focusable grid layout
   - Remote control navigation
   - Search functionality

3. **Build Departure Board**
   - Live departure data
   - Auto-refresh
   - Split-flap aesthetic

4. **Build Train Radar Map**
   - Netherlands railway map
   - Real-time train positions
   - Interactive navigation

## NS Brand Colors

- **Primary Blue**: `#003082` (backgrounds, headers)
- **NS Yellow**: `#FFC917` (highlights, accents, focused elements)
- **White**: `#FFFFFF` (text on dark backgrounds)

## Resources

- [Expo TV Documentation](https://docs.expo.dev/guides/building-for-tv/)
- [React Native tvOS](https://github.com/react-native-tvos/react-native-tvos)
- [NS API Documentation](https://apiportal.ns.nl/)

## Version

**v0.1.0** - Proof of Concept (Static Screen)

---

Built with ❤️ by Amberglass
