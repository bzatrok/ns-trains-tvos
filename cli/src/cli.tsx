import React, { useEffect, useState } from 'react';
import { Box, Text, useInput } from 'ink';
import { useNSApi } from './hooks/useNSApi.js';
import { Departure } from './types/departure.js';
import { format } from 'date-fns';
import { NetherlandsMap } from './components/NetherlandsMap.js';
import { StationSelector } from './components/StationSelector.js';

interface AppProps {
  station?: string;
  refresh?: string;
  animation?: boolean;
}

const App: React.FC<AppProps> = ({ station: stationProp, refresh = '10' }) => {
  const { fetchDepartures, loading, error } = useNSApi();
  const [departures, setDepartures] = useState<Departure[]>([]);
  const [lastUpdate, setLastUpdate] = useState<string>('');
  const [selectedStation, setSelectedStation] = useState<string | undefined>(stationProp);

  // Use selected station from interactive selector or CLI prop
  const station = selectedStation || stationProp;

  // Handle ESC key to return to station selector (only if not provided via CLI)
  useInput((_input, key) => {
    if (key.escape && !stationProp && station) {
      setSelectedStation(undefined);
      setDepartures([]);
    }
  });

  useEffect(() => {
    if (!station) return;

    const loadDepartures = async () => {
      const result = await fetchDepartures(station);
      if (result) {
        setDepartures(result.departures.slice(0, 10)); // Show first 10
        setLastUpdate(format(new Date(), 'HH:mm:ss'));
      }
    };

    loadDepartures();

    // Auto-refresh
    const interval = setInterval(loadDepartures, parseInt(refresh) * 1000);
    return () => clearInterval(interval);
  }, [station, refresh, fetchDepartures]);

  // Show station selector if no station is provided
  if (!station) {
    return (
      <StationSelector
        onSelect={(code) => setSelectedStation(code)}
        onQuit={() => process.exit(0)}
      />
    );
  }

  if (loading && departures.length === 0) {
    return (
      <Box flexDirection="column" padding={1}>
        <Text color="yellow">⏳ Loading departures for {station}...</Text>
      </Box>
    );
  }

  if (error) {
    return (
      <Box flexDirection="column" padding={1}>
        <Text color="red">❌ Error: {error}</Text>
        <Text dimColor>Check your NS_API_KEY in .env</Text>
      </Box>
    );
  }

  return (
    <Box flexDirection="row" padding={1}>
      {/* Left Column - Departure Board */}
      <Box flexDirection="column" marginRight={2}>
        {/* Header */}
        <Box borderStyle="double" borderColor="yellow" padding={1} justifyContent="center">
          <Text color="yellow" bold>
            {station.toUpperCase()} - DEPARTURES
          </Text>
        </Box>

        <Box justifyContent="center" marginTop={1}>
          <Text dimColor>Last Update: {lastUpdate}</Text>
        </Box>

        {/* Table Header */}
        <Box marginTop={1} borderStyle="single" borderColor="gray">
          <Box width={6}>
            <Text bold>TIME</Text>
          </Box>
          <Box width={8}>
            <Text bold>TRAIN</Text>
          </Box>
          <Box width={22}>
            <Text bold>DESTINATION</Text>
          </Box>
          <Box width={8}>
            <Text bold>PLAT</Text>
          </Box>
          <Box width={8}>
            <Text bold>DELAY</Text>
          </Box>
          <Box width={10}>
            <Text bold>STATUS</Text>
          </Box>
        </Box>

        {/* Departure Rows */}
        {departures.length === 0 ? (
          <Box marginTop={1}>
            <Text dimColor>No departures found</Text>
          </Box>
        ) : (
          departures.map((dep, idx) => {
            const time = dep.departureTime ? format(new Date(dep.departureTime), 'HH:mm') : '--:--';
            const delayText = dep.delay > 0 ? `+${dep.delay}` : '-';
            const statusColor = dep.cancelled ? 'red' : dep.delay > 5 ? 'red' : 'green';
            const statusText = dep.cancelled ? 'CANCEL' : dep.delay > 0 ? 'DELAYED' : 'ON TIME';

            return (
              <Box key={idx} marginTop={idx === 0 ? 1 : 0}>
                <Box width={6}>
                  <Text>{time}</Text>
                </Box>
                <Box width={8}>
                  <Text>{dep.typeCode} {dep.serviceNumber.substring(0, 4)}</Text>
                </Box>
                <Box width={22}>
                  <Text>{dep.destinationActual.substring(0, 20)}</Text>
                </Box>
                <Box width={8}>
                  <Text color={dep.platformChanged ? 'blue' : undefined}>
                    {dep.platformActual || '-'}
                  </Text>
                </Box>
                <Box width={8}>
                  <Text color={dep.delay > 0 ? 'yellow' : undefined}>{delayText}</Text>
                </Box>
                <Box width={10}>
                  <Text color={statusColor}>{statusText}</Text>
                </Box>
              </Box>
            );
          })
        )}

        {/* Footer */}
        <Box marginTop={1}>
          <Text dimColor>
            Refresh: {refresh}s | {!stationProp && 'ESC: back | '}Ctrl+C: quit
          </Text>
        </Box>
      </Box>

      {/* Right Column - Netherlands Map */}
      <Box flexDirection="column">
        <NetherlandsMap stationCode={station} />
      </Box>
    </Box>
  );
};

export default App;
