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

export function getTileMap(
    map: Map,
    x: number,
    y: number,
): TileMap | undefined {
    const layer = map.layers["ground"] ?? [];
    return layer.find((t) => t.x === x && t.y === y);
}

export function isTileMapBlocked(map: Map, x: number, y: number): boolean {
    const tile = getTileMap(map, x, y);
    return tile?.data.block === true;
}

export function isInsideMapBounds(map: Map, x: number, y: number): boolean {
    const layer = map.layers["ground"] ?? [];
    const maxX = Math.max(...layer.map((t) => t.x));
    const maxY = Math.max(...layer.map((t) => t.y));
    return x >= 0 && y >= 0 && x <= maxX && y <= maxY;
}
