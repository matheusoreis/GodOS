import sqlite from "../connectors/sqlite.js";

export type Map = {
    id: number;
    identifier: string;
    file: string;
    createdAt: Date;
    updatedAt: Date;
};

export type CreateMap = {
    identifier: string;
    file: string;
};

export type UpdateMap = {
    identifier?: string;
    file?: string;
};

export async function getMapById(mapId: number): Promise<Map | undefined> {
    return await sqlite<Map>("maps").where({ id: mapId }).first();
}

export async function getAllMaps(): Promise<Map[]> {
    return await sqlite<Map>("maps").select("*").orderBy("createdAt", "desc");
}

export async function getMapByIdentifier(
    identifier: string,
): Promise<Map | undefined> {
    return await sqlite<Map>("maps").where({ identifier: identifier }).first();
}

export async function createMap(data: CreateMap): Promise<void> {
    await sqlite<Map>("maps").insert({
        ...data,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

export async function updateMap(mapId: number, data: UpdateMap): Promise<void> {
    await sqlite<Map>("maps")
        .where({ id: mapId })
        .update({
            ...data,
            updatedAt: new Date(),
        });
}

export async function deleteMap(mapId: number): Promise<void> {
    await sqlite<Map>("maps").where({ id: mapId }).delete();
}
