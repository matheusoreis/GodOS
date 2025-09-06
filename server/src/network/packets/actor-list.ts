import type { Account } from "../../database/services/account.js";
import {
    getAllActorsByAccountId,
    type Actor,
} from "../../database/services/actor.js";
import { getAccount } from "../../modules/account.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendError } from "./error.js";
import { sendSuccess } from "./success.js";

export class ActorListError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "ActorListError";
    }
}

export async function handleActorList(id: number, _: unknown): Promise<void> {
    const packet: number = Packets.ActorList;

    try {
        const account: Account | undefined = getAccount(id);
        if (account === undefined) {
            throw new ActorListError("Usuário não está logado.");
        }

        const actors: Actor[] = await getAllActorsByAccountId(account.id);

        return sendSuccess(id, packet, {
            actors: actors.map((actor) => ({
                id: actor.id,
                identifier: actor.identifier,
                sprite: actor.sprite,
            })),
        });
    } catch (err) {
        if (err instanceof ActorListError) {
            return sendError(id, packet, err.message);
        }

        error(`Erro inesperado no actorList: ${err}`);
        return sendError(id, packet, "Erro interno no servidor.");
    }
}
