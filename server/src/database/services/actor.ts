import sqlite from "../connectors/sqlite.js";

export type Actor = {
    id: number;
    identifier: string;
    sprite: string;
    positionX: number;
    positionY: number;
    directionX: number;
    directionY: number;
    createdAt: Date;
    updatedAt: Date;
    accountId: number;
    mapId: number;
};

export type CreateActor = {
    identifier: string;
    sprite: string;
    positionX: number;
    positionY: number;
    directionX: number;
    directionY: number;
    mapId: number;
};

export type UpdateActor = {
    sprite?: string;
    positionX?: number;
    positionY?: number;
    directionX?: number;
    directionY?: number;
    mapId?: number;
};

async function getById(actorId: number): Promise<Actor | undefined> {
    return await sqlite<Actor>("actors").where({ id: actorId }).first();
}

async function getAll(): Promise<Actor[]> {
    return await sqlite<Actor>("actors")
        .select("*")
        .orderBy("createdAt", "desc");
}

async function getAllByAccountId(accountId: number): Promise<Actor[]> {
    return await sqlite<Actor>("actors").where({ accountId }).select("*");
}

async function getByIdentifier(
    accountId: number,
    identifier: string,
): Promise<Actor | undefined> {
    return await sqlite<Actor>("actors")
        .where({ identifier, accountId })
        .first();
}

async function create(accountId: number, data: CreateActor): Promise<void> {
    await sqlite<Actor>("actors").insert({
        ...data,
        accountId,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

async function updateById(
    accountId: number,
    actorId: number,
    data: UpdateActor,
): Promise<void> {
    await sqlite<Actor>("actors")
        .where({ id: actorId, accountId })
        .update({
            ...data,
            updatedAt: new Date(),
        });
}

async function deleteById(accountId: number, actorId: number): Promise<void> {
    await sqlite<Actor>("actors").where({ id: actorId, accountId }).delete();
}

export const actorDatabase = {
    getById,
    getAll,
    getAllByAccountId,
    getByIdentifier,
    create,
    updateById,
    deleteById,
};
