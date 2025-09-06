import sqlite from "../connectors/sqlite.js";
import fs from "fs/promises";
import path from "path";

export type TileMap = {
    data: {
        block: boolean;
    };
    x: number;
    y: number;
};

export type Map = {
    id: number;
    identifier: string;
    layers: Record<string, TileMap[]>;
    createdAt: Date;
    updatedAt: Date;
};

export type CreateMap = {
    identifier: string;
    presentation: string;
    file: string;
};

export type UpdateMap = {
    identifier?: string;
    presentation?: string;
    file?: string;
};

async function loadLayers(file: string): Promise<Record<string, TileMap[]>> {
    const filePath = path.join("data", "maps", `${file}.json`);
    const content = await fs.readFile(filePath, "utf-8");
    return JSON.parse(content) as Record<string, TileMap[]>;
}

async function getById(mapId: number): Promise<Map | undefined> {
    const row = await sqlite<any>("maps").where({ id: mapId }).first();
    if (!row) {
        {
            return undefined;
        }
    }

    const layers = await loadLayers(row.file);
    return { ...row, layers } as Map;
}

async function getAll(): Promise<Map[]> {
    const rows = await sqlite<any>("maps")
        .select("*")
        .orderBy("createdAt", "desc");

    const result: Map[] = [];
    for (const row of rows) {
        const layers = await loadLayers(row.file);
        result.push({ ...row, layers });
    }

    return result;
}

async function getByIdentifier(identifier: string): Promise<Map | undefined> {
    const row = await sqlite<any>("maps").where({ identifier }).first();
    if (!row) {
        return undefined;
    }

    const layers = await loadLayers(row.file);
    return { ...row, layers } as Map;
}

async function create(data: CreateMap): Promise<void> {
    await sqlite("maps").insert({
        ...data,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

async function update(mapId: number, data: UpdateMap): Promise<void> {
    await sqlite("maps")
        .where({ id: mapId })
        .update({
            ...data,
            updatedAt: new Date(),
        });
}

async function deleteById(mapId: number): Promise<void> {
    await sqlite("maps").where({ id: mapId }).delete();
}

export const mapDatabase = {
    getById,
    getAll,
    getByIdentifier,
    create,
    update,
    deleteById,
};
