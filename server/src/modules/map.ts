import type { Map } from "../database/services/map.js";

const maps = new Map<number, Map>();

export function addMap(map: Map): void {
    maps.set(map.id, map);
}

export function getMap(id: number): Map | undefined {
    return maps.get(id);
}

export function getAllMaps(): Map[] {
    return Array.from(maps.values());
}

export function removeMap(id: number): void {
    maps.delete(id);
}

export function updateMap(id: number, data: Partial<Map>): Map | undefined {
    const existing = maps.get(id);
    if (!existing) return undefined;

    const updated: Map = {
        ...existing,
        ...data,
        updatedAt: new Date(),
    };

    maps.set(id, updated);
    return updated;
}
