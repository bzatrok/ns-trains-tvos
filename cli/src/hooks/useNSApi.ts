import { useState, useCallback } from 'react';
import { Station, DeparturesResponse } from '../types/departure.js';

const API_BASE = process.env.API_URL || 'http://localhost:5000';

export function useNSApi() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchStations = useCallback(async (): Promise<Station[] | null> => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE}/api/stations`);
      if (!response.ok) throw new Error(`API error: ${response.status}`);
      const data = await response.json();
      return data;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error';
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchDepartures = useCallback(async (stationCode: string): Promise<DeparturesResponse | null> => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${API_BASE}/api/departures?station=${stationCode}`);
      if (!response.ok) throw new Error(`API error: ${response.status}`);
      const data = await response.json();
      return data;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error';
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  }, []);

  return { fetchStations, fetchDepartures, loading, error };
}
