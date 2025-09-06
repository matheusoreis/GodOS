import sqlite from "../connectors/sqlite.js";
import { getAccountById } from "./account.js";

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

export async function getActorById(id: number): Promise<Actor | undefined> {
    return await sqlite<Actor>("actors").where({ id }).first();
}

export async function getAllActors(): Promise<Actor[]> {
    return await sqlite<Actor>("actors")
        .select("*")
        .orderBy("createdAt", "desc");
}

export async function getAllActorsByAccountId(
    accountId: number,
): Promise<Actor[]> {
    const account = await getAccountById(accountId);
    if (!account) {
        throw new Error("Conta não encontrada");
    }

    return await sqlite<Actor>("actors").where({ accountId }).select("*");
}

export async function getActorByIdentifier(
    accountId: number,
    identifier: string,
): Promise<Actor | undefined> {
    const account = await getAccountById(accountId);
    if (!account) {
        throw new Error("Conta não encontrada");
    }

    return await sqlite<Actor>("actors")
        .where({ identifier, accountId })
        .first();
}

export async function createActor(
    accountId: number,
    data: CreateActor,
): Promise<void> {
    const account = await getAccountById(accountId);
    if (!account) {
        throw new Error("Conta não encontrada");
    }

    await sqlite<Actor>("actors").insert({
        ...data,
        accountId,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

export async function updateActor(
    accountId: number,
    id: number,
    data: UpdateActor,
): Promise<void> {
    const account = await getAccountById(accountId);
    if (!account) {
        throw new Error("Conta não encontrada");
    }

    await sqlite<Actor>("actors")
        .where({ id, accountId })
        .update({
            ...data,
            updatedAt: new Date(),
        });
}

export async function deleteActor(
    accountId: number,
    id: number,
): Promise<void> {
    const account = await getAccountById(accountId);
    if (!account) {
        throw new Error("Conta não encontrada");
    }

    await sqlite<Actor>("actors").where({ id, accountId }).delete();
}
