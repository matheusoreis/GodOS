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

async function getById(mapId: number): Promise<Map | undefined> {
    return await sqlite<Map>("maps").where({ id: mapId }).first();
}

async function getAll(): Promise<Map[]> {
    return await sqlite<Map>("maps").select("*").orderBy("createdAt", "desc");
}

async function getByIdentifier(identifier: string): Promise<Map | undefined> {
    return await sqlite<Map>("maps").where({ identifier: identifier }).first();
}

async function create(data: CreateMap): Promise<void> {
    await sqlite<Map>("maps").insert({
        ...data,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

async function update(mapId: number, data: UpdateMap): Promise<void> {
    await sqlite<Map>("maps")
        .where({ id: mapId })
        .update({
            ...data,
            updatedAt: new Date(),
        });
}

async function deleteById(mapId: number): Promise<void> {
    await sqlite<Map>("maps").where({ id: mapId }).delete();
}

export const mapDatabase = {
    getById,
    getAll,
    getByIdentifier,
    create,
    update,
    deleteById,
};
