import React, { useEffect, useState } from 'react';
import { Box, Text } from 'ink';
import { useNSApi } from '../hooks/useNSApi.js';
import { useKeyboardNav } from '../hooks/useKeyboardNav.js';
import { Station } from '../types/departure.js';
import { useInput } from 'ink';

interface StationSelectorProps {
  onSelect: (stationCode: string) => void;
  onQuit: () => void;
}

export const StationSelector: React.FC<StationSelectorProps> = ({ onSelect, onQuit }) => {
  const { fetchStations, loading, error } = useNSApi();
  const [stations, setStations] = useState<Station[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);

  // Fetch stations on mount
  useEffect(() => {
    const loadStations = async () => {
      const result = await fetchStations();
      if (result) {
        // Filter only Netherlands stations and sort by name
        const nlStations = result
          .filter(s => s.country === 'NL')
          .sort((a, b) => a.name.localeCompare(b.name));
        setStations(nlStations);
      }
    };
    loadStations();
  }, [fetchStations]);

  // Filter stations based on search query
  const filteredStations = stations.filter(station => {
    const query = searchQuery.toLowerCase();
    return (
      station.name.toLowerCase().includes(query) ||
      station.code.toLowerCase().includes(query)
    );
  });

  // Limit to 10 visible results
  const visibleStations = filteredStations.slice(0, 10);

  // Handle keyboard input for search
  useInput((input, key) => {
    if (key.backspace || key.delete) {
      setSearchQuery(prev => prev.slice(0, -1));
      setSelectedIndex(0);
    } else if (input && !key.ctrl && !key.meta && !key.shift && input.length === 1) {
      // Only add printable characters
      if (input.match(/^[a-zA-Z0-9\s]$/)) {
        setSearchQuery(prev => prev + input);
        setSelectedIndex(0);
      }
    }
  });

  // Handle keyboard navigation
  useKeyboardNav({
    onUp: () => {
      setSelectedIndex(prev => Math.max(0, prev - 1));
    },
    onDown: () => {
      setSelectedIndex(prev => Math.min(visibleStations.length - 1, prev + 1));
    },
    onEnter: () => {
      if (visibleStations[selectedIndex]) {
        onSelect(visibleStations[selectedIndex].code);
      }
    },
    onQuit: onQuit
  });

  if (loading) {
    return (
      <Box flexDirection="column" padding={1}>
        <Text color="yellow">⏳ Loading stations...</Text>
      </Box>
    );
  }

  if (error) {
    return (
      <Box flexDirection="column" padding={1}>
        <Text color="red">❌ Error: {error}</Text>
        <Text dimColor>Check your NS_API_KEY in .env</Text>
        <Box marginTop={1}>
          <Text dimColor>Press 'q' to quit</Text>
        </Box>
      </Box>
    );
  }

  return (
    <Box flexDirection="column" padding={1}>
      {/* Header */}
      <Box borderStyle="double" borderColor="cyan" padding={1}>
        <Text color="cyan" bold>
          🚂 NS TRAIN DEPARTURE BOARD - STATION SELECTOR
        </Text>
      </Box>

      {/* Search Input */}
      <Box marginTop={1} borderStyle="single" borderColor="blue" padding={1}>
        <Box marginRight={1}>
          <Text color="blue">Search:</Text>
        </Box>
        <Text color="white">{searchQuery}</Text>
        <Text color="gray">▏</Text>
      </Box>

      {/* Instructions */}
      <Box marginTop={1}>
        <Text dimColor>
          Type to search by name or code • ↑↓ to navigate • Enter to select • q to quit
        </Text>
      </Box>

      {/* Results */}
      <Box flexDirection="column" marginTop={1}>
        {visibleStations.length === 0 ? (
          <Box padding={1}>
            <Text color="yellow">
              {searchQuery ? `No stations found matching "${searchQuery}"` : 'No stations available'}
            </Text>
          </Box>
        ) : (
          <>
            <Box borderStyle="single" borderColor="gray" paddingX={1}>
              <Box width={30}>
                <Text bold>STATION NAME</Text>
              </Box>
              <Box width={8}>
                <Text bold>CODE</Text>
              </Box>
            </Box>
            {visibleStations.map((station, idx) => {
              const isSelected = idx === selectedIndex;
              return (
                <Box
                  key={station.code}
                  paddingX={1}
                  backgroundColor={isSelected ? 'blue' : undefined}
                >
                  <Box width={30}>
                    <Text color={isSelected ? 'white' : undefined}>
                      {isSelected ? '→ ' : '  '}
                      {station.name}
                    </Text>
                  </Box>
                  <Box width={8}>
                    <Text color={isSelected ? 'white' : 'cyan'}>
                      {station.code}
                    </Text>
                  </Box>
                </Box>
              );
            })}
          </>
        )}
      </Box>

      {/* Footer */}
      <Box marginTop={1}>
        <Text dimColor>
          Showing {visibleStations.length} of {filteredStations.length} stations
          {filteredStations.length > 10 && ' (scroll to see more)'}
        </Text>
      </Box>
    </Box>
  );
};
