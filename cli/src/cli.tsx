import React from 'react';
import { Box, Text } from 'ink';

interface AppProps {
  station?: string;
  refresh?: string;
  animation?: boolean;
}

const App: React.FC<AppProps> = ({ station, refresh = '10', animation = true }) => {
  return (
    <Box flexDirection="column" padding={1}>
      <Box borderStyle="double" borderColor="yellow" padding={1}>
        <Text color="yellow" bold>
          Amberglass CLI - NS Train Departure Board
        </Text>
      </Box>
      <Box marginTop={1}>
        <Text dimColor>
          Station: {station || 'Not specified'}
        </Text>
      </Box>
      <Box>
        <Text dimColor>
          Refresh interval: {refresh}s
        </Text>
      </Box>
      <Box>
        <Text dimColor>
          Animation: {animation ? 'Enabled' : 'Disabled'}
        </Text>
      </Box>
      <Box marginTop={1}>
        <Text color="green">
          ✓ CLI initialized successfully
        </Text>
      </Box>
    </Box>
  );
};

export default App;
