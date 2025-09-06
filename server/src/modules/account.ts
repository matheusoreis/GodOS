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

export const actors: Array<Actor | undefined> = Array(
    Number(process.env.CAPACITY ?? 0),
).fill(undefined);

export function addActor(id: number, actor: Actor): void {
    actors[id] = actor;
}

export function getActor(id: number): Actor | undefined {
    return actors[id];
}

export function getAllActors(): Actor[] {
    return actors.filter(function (actor): actor is Actor {
        return actor !== undefined;
    });
}

export function removeActor(id: number): void {
    actors[id] = undefined;
}

export function updateActor(id: number, data: Partial<Actor>) {
    const actor = getActor(id);
    if (!actor) {
        return undefined;
    }

    const updatedActor: Actor = {
        ...actor,
        ...data,
        updatedAt: new Date(),
    };

    actors[id] = updatedActor;
    return updatedActor;
}
