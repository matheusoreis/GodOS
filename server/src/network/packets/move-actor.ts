import type { Account } from "../../database/services/account.js";
import { getAccount } from "../../modules/account.js";
import { getActor, moveActor } from "../../modules/actor.js";
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

    console.log(data);

    try {
        const account: Account | undefined = getAccount(clientId);
        if (!account) {
            throw new MoveActorError("Usuário não está logado.");
        }

        const actor = getActor(clientId);
        if (!actor) {
            throw new MoveActorError("Personagem não encontrado.");
        }

        const direction = { x: data.directionX, y: data.directionY };

        const moved = moveActor(clientId, direction);
        if (!moved) {
            throw new MoveActorError("Movimento inválido.");
        }

        // sendSuccess(clientId, packet, {
        //     actorId: moved.id,
        //     positionX: moved.positionX,
        //     positionY: moved.positionY,
        //     directionX: moved.directionX,
        //     directionY: moved.directionY,
        // });

        sendToMapBut(moved.mapId, clientId, {
            id: packet,
            data: {
                actorId: moved.id,
                positionX: moved.positionX,
                positionY: moved.positionY,
                directionX: moved.directionX,
                directionY: moved.directionY,
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
