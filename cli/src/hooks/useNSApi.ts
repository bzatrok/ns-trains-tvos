import { useState, useCallback } from 'react';
import { Station, DeparturesResponse, Departure } from '../types/departure.js';

// Load environment variables
const NS_API_KEY = process.env.NS_API_KEY || '';
const NS_API_BASE = process.env.NS_API_BASE_URL || 'https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2';

// Cache for API results (module-level to persist across component re-renders)
let stationsCache: Station[] | null = null;

// Helper to transform NS API snake_case to camelCase
function transformDeparture(nsData: any): Departure {
  // Calculate delay in minutes by comparing planned vs actual departure time
  let delayMinutes = 0;
  if (nsData.plannedDateTime && nsData.actualDateTime) {
    const planned = new Date(nsData.plannedDateTime);
    const actual = new Date(nsData.actualDateTime);
    delayMinutes = Math.round((actual.getTime() - planned.getTime()) / (1000 * 60));
  }

  return {
    cancelled: nsData.cancelled || false,
    company: nsData.product?.operatorName || nsData.company || 'NS',
    delay: delayMinutes,
    departureTime: nsData.plannedDateTime || nsData.actualDateTime || '',
    destinationActual: nsData.direction || nsData.destination_actual || '',
    destinationActualCodes: nsData.routeStations?.map((s: any) => s.uicCode) || [],
    destinationPlanned: nsData.direction || nsData.destination_planned || '',
    platformActual: nsData.actualTrack || nsData.plannedTrack || '',
    platformChanged: nsData.actualTrack !== nsData.plannedTrack,
    platformPlanned: nsData.plannedTrack || '',
    serviceNumber: nsData.product?.number || nsData.trainNumber?.toString() || '',
    type: nsData.product?.longCategoryName || nsData.trainCategory || 'Intercity',
    typeCode: nsData.product?.categoryCode || nsData.type_code || 'IC',
    remarks: nsData.messages?.map((m: any) => m.message) || [],
    via: nsData.routeStations?.slice(1, -1).map((s: any) => s.mediumName).join(', ') || ''
  };
}

export function useNSApi() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchStations = useCallback(async (): Promise<Station[] | null> => {
    // Return cached stations if available
    if (stationsCache) {
      return stationsCache;
    }

    setLoading(true);
    setError(null);
    try {
      const response = await fetch(`${NS_API_BASE}/stations`, {
        headers: {
          'Ocp-Apim-Subscription-Key': NS_API_KEY
        }
      });
      if (!response.ok) throw new Error(`NS API error: ${response.status}`);
      const data = await response.json() as any;

      // Transform NS API response to our Station interface
      const stations: Station[] = data.payload?.map((s: any) => ({
        code: s.code,
        name: s.namen?.lang || s.name,
        country: s.land || s.country || 'NL',
        uicCode: s.UICCode || s.uicCode
      })) || [];

      // Cache the results
      stationsCache = stations;

      return stations;
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
      const response = await fetch(`${NS_API_BASE}/departures?station=${stationCode}`, {
        headers: {
          'Ocp-Apim-Subscription-Key': NS_API_KEY
        }
      });
      if (!response.ok) throw new Error(`NS API error: ${response.status}`);
      const data = await response.json() as any;

      // Transform NS API response to our DeparturesResponse interface
      const departures: Departure[] = (data.payload?.departures || []).map(transformDeparture);

      return {
        departures,
        status: 'success'
      };
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
