import {
    deleteActorById,
    readActorById,
} from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendFailure, sendSuccess } from "../sender.js";

export type DeleteActorData = {
    actorId: number;
};

export class DeleteActorError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "DeleteActorError";
    }
}

export async function handleDeleteActor(
    clientId: number,
    data: DeleteActorData,
): Promise<void> {
    const packetId: number = Packets.DeleteActor;

    try {
        const account = getAccount(clientId);
        if (!account) {
            throw new DeleteActorError("Usuário não está logado.");
        }

        const { actorId } = data;

        const actor = await readActorById(actorId);
        if (!actor) {
            throw new DeleteActorError("Personagem não encontrado.");
        }

        if (actor.accountId !== account.id) {
            throw new DeleteActorError(
                "Você não tem permissão para apagar este personagem.",
            );
        }

        await deleteActorById(account.id, actorId);

        sendSuccess(
            clientId,
            packetId,
            {},
            `Personagem ${actor.identifier} apagado com sucesso!`,
        );
    } catch (err) {
        if (err instanceof DeleteActorError) {
            return sendFailure(clientId, packetId, err.message);
        }

        error(`Erro inesperado no deleteActor: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
