import { readAllActorsByAccountId } from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendTo } from "../sender.js";

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
        if (account === undefined) {
            throw new ActorListError("Usuário não está logado.");
        }

        const actors = await readAllActorsByAccountId(account.id);

        return sendTo(clientId, {
            id: packetId,
            data: {
                maxActors: account.maxActors,
                actors: actors.map((actor) => ({
                    id: actor.id,
                    identifier: actor.identifier,
                    sprite: actor.sprite,
                })),
            },
        });
    } catch (err) {
        if (err instanceof ActorListError) {
            sendTo(clientId, {
                id: packetId,
                data: {
                    success: false,
                    message: err.message,
                },
            });

            return;
        }

        error(`Erro inesperado no actorList: ${err}`);
        sendTo(clientId, {
            id: packetId,
            data: {
                success: false,
                message: "Erro interno no servidor.",
            },
        });
    }
}
