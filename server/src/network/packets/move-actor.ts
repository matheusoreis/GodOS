import type { Account } from "../../database/services/account.js";
import type { Actor } from "../../database/services/actor.js";
import { getAccount } from "../../modules/account.js";
import { getActor, patchActor } from "../../modules/actor.js";
import {
    getMapById,
    isTileMapBlocked,
    isInsideMapBounds,
} from "../../modules/map.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendToMapBut } from "../sender.js";
import { sendError } from "./error.js";

export type MoveActorData = {
    directionX: number;
    directionY: number;
};

export class MoveActorError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "MoveActorError";
    }
}

export async function handleMoveActor(
    clientId: number,
    data: MoveActorData,
): Promise<void> {
    const packet: number = Packets.MoveActor;

    try {
        const account: Account | undefined = getAccount(clientId);
        if (!account) {
            throw new MoveActorError("Usuário não está logado.");
        }

        const actor = getActor(clientId);
        if (!actor) {
            throw new MoveActorError("Personagem não encontrado.");
        }

        const map = getMapById(actor.mapId);
        if (!map) {
            throw new MoveActorError("Mapa não encontrado.");
        }

        const { directionX, directionY } = data;

        const newPositionX = actor.positionX + directionX;
        const newPositionY = actor.positionY + directionY;

        // if (isInsideBounds(map, newPositionX, newPositionY) === false) {
        //     throw new MoveActorError("Fora dos limites do mapa.");
        // }

        if (isTileMapBlocked(map, newPositionX, newPositionY)) {
            throw new MoveActorError("Tile bloqueada.");
        }

        const moved: Actor | undefined = patchActor(clientId, {
            positionX: newPositionX,
            positionY: newPositionY,
            directionX: directionX,
            directionY: directionY,
        });
        if (moved === undefined) {
            throw new MoveActorError("Erro ao atualizar posição.");
        }

        sendToMapBut(moved.mapId, clientId, {
            id: packet,
            data: {
                actorId: moved.id,
                positionX: newPositionX,
                positionY: newPositionY,
                directionX: directionX,
                directionY: directionY,
            },
        });
    } catch (err) {
        if (err instanceof MoveActorError) {
            return sendError(clientId, packet, err.message);
        }

        error(`Erro inesperado no handleMoveActor: ${err}`);
        return sendError(clientId, packet, "Erro interno no servidor.");
    }
}
