import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.logo}>NS</Text>
      </View>

      <Text style={styles.title}>NS Trains tvOS</Text>
      <Text style={styles.subtitle}>Proof of Concept</Text>

      <View style={styles.infoBox}>
        <Text style={styles.infoText}>🚂 Dutch Railway Departures</Text>
        <Text style={styles.infoText}>📺 Optimized for Apple TV</Text>
        <Text style={styles.infoText}>⚡ Real-time Updates</Text>
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerText}>Amberglass NS Trains</Text>
        <Text style={styles.version}>v0.1.0 POC</Text>
      </View>

      <StatusBar style="light" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#003082', // NS Blue
    alignItems: 'center',
    justifyContent: 'center',
    padding: 60,
  },
  header: {
    position: 'absolute',
    top: 80,
    left: 80,
  },
  logo: {
    fontSize: 120,
    fontWeight: 'bold',
    color: '#FFC917', // NS Yellow
    letterSpacing: 8,
  },
  title: {
    fontSize: 96,
    fontWeight: 'bold',
    color: '#FFC917', // NS Yellow
    marginBottom: 24,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 48,
    color: '#FFFFFF',
    marginBottom: 80,
    opacity: 0.9,
  },
  infoBox: {
    backgroundColor: 'rgba(255, 201, 23, 0.1)', // Translucent yellow
    borderRadius: 16,
    padding: 40,
    marginBottom: 60,
    borderWidth: 2,
    borderColor: '#FFC917',
  },
  infoText: {
    fontSize: 36,
    color: '#FFFFFF',
    marginVertical: 12,
    textAlign: 'center',
  },
  footer: {
    position: 'absolute',
    bottom: 60,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 28,
    color: '#FFFFFF',
    opacity: 0.7,
  },
  version: {
    fontSize: 24,
    color: '#FFC917',
    marginTop: 8,
    opacity: 0.8,
  },
});
