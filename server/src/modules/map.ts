import type { Map } from "../database/services/map.js";

const maps = new Map<number, Map>();

export function addMap(map: Map): void {
    maps.set(map.id, map);
}

export function getMap(mapId: number): Map | undefined {
    return maps.get(mapId);
}

export function getAllMaps(): Map[] {
    return Array.from(maps.values());
}

export function removeMap(mapId: number): void {
    maps.delete(mapId);
}

export function updateMap(mapId: number, data: Partial<Map>): Map | undefined {
    const existing = maps.get(mapId);
    if (!existing) return undefined;

    const updated: Map = {
        ...existing,
        ...data,
        updatedAt: new Date(),
    };

    maps.set(mapId, updated);
    return updated;
}
