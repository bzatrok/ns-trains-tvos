export interface Station {
  code: string;
  name: string;
  country: string;
  uicCode?: string;
}

export interface Departure {
  cancelled: boolean;
  company: string;
  delay: number;
  departureTime: string;
  destinationActual: string;
  destinationActualCodes: string[];
  destinationPlanned: string;
  platformActual: string;
  platformChanged: boolean;
  platformPlanned: string;
  serviceNumber: string;
  type: string;
  typeCode: string;
  remarks?: string[];
  via?: string;
}

export interface DeparturesResponse {
  departures: Departure[];
  status: string;
}
