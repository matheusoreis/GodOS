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

export async function readActorById(
    actorId: number,
): Promise<Actor | undefined> {
    return await sqlite<Actor>("actors").where({ id: actorId }).first();
}

export async function readAllActors(): Promise<Actor[]> {
    return await sqlite<Actor>("actors")
        .select("*")
        .orderBy("createdAt", "desc");
}

export async function readAllActorsByAccountId(
    accountId: number,
): Promise<Actor[]> {
    return await sqlite<Actor>("actors").where({ accountId }).select("*");
}

export async function readActorByIdentifier(
    accountId: number,
    identifier: string,
): Promise<Actor | undefined> {
    return await sqlite<Actor>("actors")
        .where({ identifier, accountId })
        .first();
}

export async function createActor(
    accountId: number,
    data: CreateActor,
): Promise<void> {
    await sqlite<Actor>("actors").insert({
        ...data,
        accountId,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

export async function updateActorById(
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

export async function deleteActorById(
    accountId: number,
    actorId: number,
): Promise<void> {
    await sqlite<Actor>("actors").where({ id: actorId, accountId }).delete();
}
