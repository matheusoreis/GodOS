import { readAllActorsByAccountId } from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendFailure, sendSuccess } from "../sender.js";

export class ActorListError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "ActorListError";
    }
}

export async function handleActorList(
    clientId: number,
    _: unknown,
): Promise<void> {
    const packetId: number = Packets.ActorList;

    try {
        const account = getAccount(clientId);
        if (!account) {
            throw new ActorListError("Usuário não está logado.");
        }

        const actors = await readAllActorsByAccountId(account.id);

        sendSuccess(clientId, packetId, {
            maxActors: account.maxActors,
            actors: actors.map((actor) => ({
                id: actor.id,
                identifier: actor.identifier,
                sprite: actor.sprite,
            })),
        });
    } catch (err) {
        if (err instanceof ActorListError) {
            return sendFailure(clientId, packetId, err.message);
        }

        error(`Erro inesperado no actorList: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
