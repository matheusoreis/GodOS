import type { Account } from "../../database/services/account.js";
import {
    createActor as createActorInDb,
    getActorByIdentifier,
    type Actor,
} from "../../database/services/actor.js";
import { getAccount } from "../../modules/account.js";
import { error } from "../../shared/logger.js";
import { validateUsername } from "../../shared/validation.js";
import { Packets } from "../handler.js";
import { sendError } from "./error.js";
import { sendSuccess } from "./success.js";

export type CreateActorData = {
    identifier: string;
    sprite: string;
};

export class CreateActorError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "CreateActorError";
    }
}

export async function handleCreateActor(
    clientId: number,
    data: CreateActorData,
): Promise<void> {
    const packet: number = Packets.CreateActor;

    try {
        const account: Account | undefined = getAccount(clientId);
        if (account === undefined) {
            throw new CreateActorError("Usuário não está logado.");
        }

        const { identifier, sprite } = data;

        if (validateUsername(identifier).isValid === false) {
            throw new CreateActorError("Nome do personagem inválido.");
        }

        if (sprite === undefined || sprite.trim() === "") {
            throw new CreateActorError("Sprite inválido.");
        }

        const lowerIdentifier = identifier.toLowerCase();

        const existing: Actor | undefined = await getActorByIdentifier(
            account.id,
            lowerIdentifier,
        );
        if (existing !== undefined) {
            throw new CreateActorError("Nome de personagem já está em uso.");
        }

        await createActorInDb(account.id, {
            identifier: lowerIdentifier,
            sprite,
            positionX: Number(process.env.START_MAP_X ?? "1"),
            positionY: Number(process.env.START_MAP_Y ?? "1"),
            directionX: 0,
            directionY: 1,
            mapId: Number(process.env.START_MAP ?? "1"),
        });

        return sendSuccess(clientId, packet, {
            message: "Personagem criado com sucesso!",
        });
    } catch (err) {
        if (err instanceof CreateActorError) {
            return sendError(clientId, packet, err.message);
        }

        error(`Erro inesperado no createActor: ${err}`);
        return sendError(clientId, packet, "Erro interno no servidor.");
    }
}
