// ASCII map of the Netherlands with station positions

export const NL_MAP_WIDTH = 42;
export const NL_MAP_HEIGHT = 32;

// Station coordinates (row, col) on the ASCII map
export interface StationPosition {
  row: number;
  col: number;
  name: string;
}

export const STATION_POSITIONS: Record<string, StationPosition> = {
  // North
  'GN': { row: 3, col: 39, name: 'Groningen' },
  'LW': { row: 3, col: 18, name: 'Leeuwarden' },
  'ASN': { row: 4, col: 34, name: 'Assen' },

  // North-Central
  'ZL': { row: 10, col: 18, name: 'Zwolle' },
  'DV': { row: 11, col: 20, name: 'Deventer' },

  // Randstad - Amsterdam area
  'HLM': { row: 12, col: 4, name: 'Haarlem' },
  'ASD': { row: 12, col: 8, name: 'Amsterdam Centraal' },
  'ASS': { row: 12, col: 6, name: 'Amsterdam Sloterdijk' },
  'ASDZ': { row: 13, col: 15, name: 'Amsterdam Zuid' },
  'UT': { row: 13, col: 20, name: 'Utrecht Centraal' },
  'AML': { row: 12, col: 15, name: 'Amersfoort' },

  // Randstad - Den Haag / Rotterdam
  'GVC': { row: 16, col: 2, name: 'Den Haag' },
  'DT': { row: 16, col: 6, name: 'Delft' },
  'RTD': { row: 16, col: 10, name: 'Rotterdam' },
  'GD': { row: 17, col: 9, name: 'Gouda' },

  // East
  'AH': { row: 16, col: 28, name: 'Arnhem' },
  'NM': { row: 16, col: 33, name: 'Nijmegen' },
  'ES': { row: 13, col: 36, name: 'Enschede' },

  // South
  'HT': { row: 20, col: 16, name: "'s-Hertogenbosch" },
  'TB': { row: 22, col: 10, name: 'Tilburg' },
  'EHV': { row: 22, col: 20, name: 'Eindhoven' },
  'BD': { row: 23, col: 6, name: 'Breda' },
  'VL': { row: 25, col: 25, name: 'Venlo' },
  'MT': { row: 29, col: 23, name: 'Maastricht' },
};

const MAP_TEMPLATE = [
  '╔════════════════════════════════════════╗',
  '║ ~~~~ NORTH SEA                         ║',
  '║ ~~~~          _______________          ║',
  '║ ~~~         /  FRIESLAND  ·  \\____   • ║',
  '║ ~~        /   ·                   \\  · ║',
  '║ ~       /                          \\___║',
  '║~      /           ≈≈≈≈≈≈              \\║',
  '║~     |          ≈≈IJssel≈≈             |║',
  '║~    |          ≈≈≈meer≈≈≈       ·      |║',
  '║~   |                                   |║',
  '║~  |                  ·                 |║',
  '║~ |   · ·  ·      ·                     |║',
  '║~ |      ·   RANDSTAD  ·           ·    |║',
  '║~ |                ·  UTRECHT        ·  |║',
  '║~|                                      |║',
  '║~| ·  · ·                    ·   GELD.  |║',
  '║~|    ·   ·                      ·     /║',
  '║~~\\                                   / ║',
  '║ ~~\\                                 /  ║',
  '║  ~~\\                               /   ║',
  '║   ~~\\              ·  N.BRABANT  /    ║',
  '║    ~~\\         ·                /     ║',
  '║     ~~\\ ·           ·          /      ║',
  '║      ~~\\                      /       ║',
  '║       ~~\\                 ·  /        ║',
  '║        ~~\\                  /         ║',
  '║         ~~\\                /          ║',
  '║          ~~\\    LIMBURG   /           ║',
  '║           ~~\\          · /            ║',
  '║            ~~\\__________/             ║',
  '║             ~~~                        ║',
  '╚════════════════════════════════════════╝',
];

export function getMapWithStation(stationCode: string): {
  lines: string[];
  stationName: string | null;
} {
  const position = STATION_POSITIONS[stationCode];

  if (!position) {
    // Station not in map
    return {
      lines: [
        ...MAP_TEMPLATE,
        '',
        ` Station: ${stationCode}`,
        ' (not shown on map)',
      ],
      stationName: null,
    };
  }

  // Create a copy of the map
  const mapCopy = MAP_TEMPLATE.map(line => line.split(''));

  // Mark the current station with ★
  if (mapCopy[position.row] && mapCopy[position.row][position.col]) {
    mapCopy[position.row][position.col] = '★';
  }

  // Convert back to strings
  const mapLines = mapCopy.map(chars => chars.join(''));

  // Add station indicator at bottom
  return {
    lines: [
      ...mapLines,
      '',
      ` ★ ${position.name}`,
    ],
    stationName: position.name,
  };
}
