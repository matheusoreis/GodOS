import type { Actor } from "../database/services/actor.js";

const actors = new Map<number, Actor>();

export function addActor(clientId: number, actor: Actor): void {
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

export function hasPlayersInMap(mapId: number): boolean {
    return getAllActorsInMap(mapId).length > 0;
}

export function removeActor(clientId: number): void {
    actors.delete(clientId);

    // sendToAllBut(clientId, {
    //     id: Packets.Disconnect,
    //     data: {
    //         clientId: clientId,
    //     },
    // });
}

export function updateActor(
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
