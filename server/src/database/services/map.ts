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

export async function getMapById(id: number): Promise<Map | undefined> {
    return await sqlite<Map>("maps").where({ id }).first();
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

export async function updateMap(id: number, data: UpdateMap): Promise<void> {
    await sqlite<Map>("maps")
        .where({ id })
        .update({
            ...data,
            updatedAt: new Date(),
        });
}

export async function deleteMap(id: number): Promise<void> {
    await sqlite<Map>("maps").where({ id }).delete();
}
