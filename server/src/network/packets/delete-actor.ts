import type { Account } from "../../database/services/account.js";
import {
    deleteActor,
    getActorById,
    type Actor,
} from "../../database/services/actor.js";
import { getAccount } from "../../modules/account.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendError } from "./error.js";
import { sendSuccess } from "./success.js";

export type DeleteActorData = {
    id: number;
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
    const packet: number = Packets.DeleteActor;

    try {
        const account: Account | undefined = getAccount(clientId);
        if (account === undefined) {
            throw new DeleteActorError("Usuário não está logado.");
        }

        const { id } = data;

        const actor: Actor | undefined = await getActorById(id);
        if (actor === undefined) {
            throw new DeleteActorError("Personagem não encontrado.");
        }

        if (actor.accountId !== account.id) {
            throw new DeleteActorError(
                "Você não tem permissão para apagar este personagem.",
            );
        }

        await deleteActor(account.id, id);

        return sendSuccess(clientId, packet, {
            message: "Personagem apagado com sucesso.",
        });
    } catch (err) {
        if (err instanceof DeleteActorError) {
            return sendError(clientId, packet, err.message);
        }

        error(`Erro inesperado no deleteActor: ${err}`);
        return sendError(clientId, packet, "Erro interno no servidor.");
    }
}
