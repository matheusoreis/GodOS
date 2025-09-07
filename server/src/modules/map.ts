import {
    mapDatabase,
    type Map,
    type TileMap,
} from "../database/services/map.js";
import { info } from "../shared/logger.js";
import { hasPlayersInMap } from "./actor.js";

const maps = new Map<number, Map>();

export async function loadMaps() {
    const allMaps: Map[] = await mapDatabase.getAll();
    for (const map of allMaps) {
        info(`Mapa ${map.identifier} carregado com sucesso!`);
        addMap(map);
    }
}

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

export function getTile(map: Map, x: number, y: number): TileMap | undefined {
    const layer = map.layers["ground"] ?? [];
    return layer.find((t) => t.x === x && t.y === y);
}

export function isBlocked(map: Map, x: number, y: number): boolean {
    const tile = getTile(map, x, y);
    return tile?.data.block === true;
}

export function isInsideBounds(map: Map, x: number, y: number): boolean {
    const layer = map.layers["ground"] ?? [];
    const maxX = Math.max(...layer.map((t) => t.x));
    const maxY = Math.max(...layer.map((t) => t.y));
    return x >= 0 && y >= 0 && x <= maxX && y <= maxY;
}

export function mapLoop() {
    for (const map of getAllMaps()) {
        if (hasPlayersInMap(map.id) === false) {
            continue;
        }
    }
}
