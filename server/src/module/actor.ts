import { updateActorById, type Actor } from "../database/services/actor.js";
import { Packets } from "../network/handler.js";
import { sendToMapBut } from "../network/sender.js";
import { getAccount } from "./account.js";

const actors = new Map<number, Actor>();

export function setActor(clientId: number, actor: Actor): void {
    actors.set(clientId, actor);
}

export function getActor(clientId: number): Actor | undefined {
    return actors.get(clientId);
}

export function getAllActors(): Actor[] {
    return Array.from(actors.values());
}

export function getAllActorsInMap(mapId: number): Actor[] {
    return Array.from(actors.values()).filter((actor) => actor.mapId === mapId);
}

export function hasActorsInMap(mapId: number): boolean {
    return getAllActorsInMap(mapId).length > 0;
}

export async function removeActor(clientId: number): Promise<void> {
    var actor = getActor(clientId);
    if (actor === undefined) {
        return;
    }

    var account = getAccount(clientId);
    if (account === undefined) {
        return;
    }

    sendToMapBut(actor.mapId, clientId, {
        id: Packets.Disconnect,
        data: {
            actorId: actor.id,
        },
    });

    await updateActorById(account.id, actor.id, {
        positionX: actor.positionX,
        positionY: actor.positionY,
        directionX: actor.directionX,
        directionY: actor.directionY,
        mapId: actor.mapId,
    });

    actors.delete(clientId);
}

export function patchActor(
    clientId: number,
    data: Partial<Actor>,
): Actor | undefined {
    const actor = actors.get(clientId);
    if (!actor) return undefined;

    const updated: Actor = {
        ...actor,
        ...data,
        updatedAt: new Date(),
    };

    actors.set(clientId, updated);
    return updated;
}
