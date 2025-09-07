import {
    readAllMaps,
    type Map,
    type TileMap,
} from "../database/services/map.js";
import { info } from "../shared/logger.js";

const maps = new Map<number, Map>();

export async function loadMaps() {
    const allMaps: Map[] = await readAllMaps();
    for (const map of allMaps) {
        info(`Mapa ${map.identifier} carregado com sucesso!`);
        setMap(map);
    }
}

export function setMap(map: Map): void {
    maps.set(map.id, map);
}

export function getMapById(mapId: number): Map | undefined {
    return maps.get(mapId);
}

export function getAllMaps(): Map[] {
    return Array.from(maps.values());
}

export function removeMap(mapId: number): void {
    maps.delete(mapId);
}

export function patchMapById(
    mapId: number,
    data: Partial<Map>,
): Map | undefined {
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

export function getTileAt(map: Map, x: number, y: number): TileMap[] {
    const tiles: TileMap[] = [];

    for (const layer of Object.values(map.layers)) {
        const found = layer.find((t) => t.x === x && t.y === y);
        if (found) {
            tiles.push(found);
        }
    }

    return tiles;
}

export function isTileMapBlocked(map: Map, x: number, y: number): boolean {
    const tiles = getTileAt(map, x, y);
    return tiles.some((tile) => tile.data.block === true);
}

export function getMapBounds(map: Map) {
    let first = true;
    let minX = 0,
        minY = 0,
        maxX = 0,
        maxY = 0;

    for (const layer of Object.values(map.layers)) {
        for (const tile of layer) {
            if (first) {
                minX = maxX = tile.x;
                minY = maxY = tile.y;
                first = false;
            } else {
                minX = Math.min(minX, tile.x);
                minY = Math.min(minY, tile.y);
                maxX = Math.max(maxX, tile.x);
                maxY = Math.max(maxY, tile.y);
            }
        }
    }

    if (first) {
        return { minX: 0, minY: 0, maxX: 0, maxY: 0 };
    }

    return { minX, minY, maxX, maxY };
}

export function isInsideMapBounds(map: Map, x: number, y: number): boolean {
    const { minX, minY, maxX, maxY } = getMapBounds(map);
    return x >= minX && y >= minY && x <= maxX && y <= maxY;
}
