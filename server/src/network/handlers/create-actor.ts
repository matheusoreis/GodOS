import {
    createActor,
    readActorByIdentifier,
} from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { error } from "../../shared/logger.js";
import { validateUsername } from "../../shared/validation.js";
import { Packets } from "../handler.js";
import { sendFailure, sendSuccess } from "../sender.js";

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
    const packetId: number = Packets.CreateActor;

    try {
        const { identifier, sprite } = data;

        const account = getAccount(clientId);
        if (!account) {
            throw new CreateActorError("Usuário não está logado.");
        }

        if (!validateUsername(identifier).isValid) {
            throw new CreateActorError("Nome do personagem inválido.");
        }

        if (!sprite || sprite.trim() === "") {
            throw new CreateActorError("Sprite inválido.");
        }

        const lowerIdentifier = identifier.toLowerCase();

        const existing = await readActorByIdentifier(
            account.id,
            lowerIdentifier,
        );
        if (existing) {
            throw new CreateActorError("Nome de personagem já está em uso.");
        }

        await createActor(account.id, {
            identifier: lowerIdentifier,
            sprite,
            positionX: Number(process.env.START_MAP_X ?? "1"),
            positionY: Number(process.env.START_MAP_Y ?? "1"),
            directionX: 0,
            directionY: 1,
            mapId: Number(process.env.START_MAP ?? "1"),
        });

        sendSuccess(
            clientId,
            packetId,
            {},
            `Personagem ${lowerIdentifier} criado com sucesso!`,
        );
    } catch (err) {
        if (err instanceof CreateActorError) {
            return sendFailure(clientId, packetId, err.message);
        }

        error(`Erro inesperado no createActor: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
