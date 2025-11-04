import React from 'react';
import { Box, Text } from 'ink';
import { getMapWithStation } from '../utils/nlMap.js';

interface NetherlandsMapProps {
  stationCode: string;
}

export const NetherlandsMap: React.FC<NetherlandsMapProps> = ({ stationCode }) => {
  const { lines } = getMapWithStation(stationCode);

  return (
    <Box flexDirection="column" paddingLeft={1}>
      {lines.map((line, idx) => {
        // Check if this is the station name line at the bottom
        const isStationLabel = line.trim().startsWith('★');

        if (isStationLabel) {
          return (
            <Box key={idx}>
              <Text color="cyan" bold>{line}</Text>
            </Box>
          );
        }

        // Render line with colored characters
        return (
          <Box key={idx}>
            <Text>
              {line.split('').map((char, charIdx) => {
                // Water (North Sea)
                if (char === '~') {
                  return <Text key={charIdx} color="blue">{char}</Text>;
                }
                // IJsselmeer (inland water)
                if (char === '≈') {
                  return <Text key={charIdx} color="cyan">{char}</Text>;
                }
                // Current station
                if (char === '★') {
                  return <Text key={charIdx} color="yellow" bold>{char}</Text>;
                }
                // Other stations
                if (char === '•' || char === '·') {
                  return <Text key={charIdx} dimColor>{char}</Text>;
                }
                // Border/outline characters
                if ('╔╗╚╝═║/\\|_'.includes(char)) {
                  return <Text key={charIdx} color="green">{char}</Text>;
                }
                // Regular text
                return <Text key={charIdx}>{char}</Text>;
              })}
            </Text>
          </Box>
        );
      })}
    </Box>
  );
};
