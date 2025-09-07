import type { Account } from "../../database/services/account.js";
import type { Actor } from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { getActor, patchActor } from "../../module/actor.js";
import {
    getMapById,
    isInsideMapBounds,
    isTileMapBlocked,
} from "../../module/map.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendFailure, sendTo, sendToMapBut } from "../sender.js";

export type MoveActorData = {
    directionX: number;
    directionY: number;
};

export class MoveActorContextError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "MoveActorContextError";
    }
}

export class MoveActorPositionError extends Error {
    lastValid: {
        actorId: number;
        positionX: number;
        positionY: number;
        directionX: number;
        directionY: number;
    };

    constructor(message: string, actor: Actor) {
        super(message);
        this.name = "MoveActorPositionError";
        this.lastValid = {
            actorId: actor.id,
            positionX: actor.positionX,
            positionY: actor.positionY,
            directionX: actor.directionX,
            directionY: actor.directionY,
        };
    }
}

export async function handleMoveActor(
    clientId: number,
    data: MoveActorData,
): Promise<void> {
    const packetId: number = Packets.MoveActor;

    try {
        const { directionX, directionY } = data;

        const account: Account | undefined = getAccount(clientId);
        if (!account) {
            throw new MoveActorContextError("Usuário não está logado.");
        }

        const actor = getActor(clientId);
        if (!actor) {
            throw new MoveActorContextError("Personagem não encontrado.");
        }

        const map = getMapById(actor.mapId);
        if (!map) {
            throw new MoveActorContextError("Mapa não encontrado.");
        }

        const newPositionX = actor.positionX + directionX;
        const newPositionY = actor.positionY + directionY;

        if (!isInsideMapBounds(map, newPositionX, newPositionY)) {
            throw new MoveActorPositionError(
                "Fora dos limites do mapa.",
                actor,
            );
        }

        if (isTileMapBlocked(map, newPositionX, newPositionY)) {
            console.log("movimento inválido");
            throw new MoveActorPositionError("Tile bloqueado.", actor);
        }

        const moved = patchActor(clientId, {
            positionX: newPositionX,
            positionY: newPositionY,
            directionX,
            directionY,
        });
        if (!moved) {
            throw new MoveActorPositionError(
                "Erro ao atualizar posição.",
                actor,
            );
        }

        // notifica outros personagens do mapa
        sendToMapBut(moved.mapId, clientId, {
            id: packetId,
            data: {
                actorId: moved.id,
                positionX: newPositionX,
                positionY: newPositionY,
                directionX,
                directionY,
            },
        });
    } catch (err) {
        if (err instanceof MoveActorContextError) {
            return sendFailure(clientId, packetId, err.message);
        }

        if (err instanceof MoveActorPositionError) {
            return sendTo(clientId, {
                id: packetId,
                data: {
                    success: false,
                    message: err.message ?? "Movimento inválido",
                    lastValid: err.lastValid,
                },
            });
        }

        error(`Erro inesperado no moveActor: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
