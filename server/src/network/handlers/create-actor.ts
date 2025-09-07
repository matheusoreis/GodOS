import {
    createActor,
    readActorByIdentifier,
} from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { error } from "../../shared/logger.js";
import { validateUsername } from "../../shared/validation.js";
import { Packets } from "../handler.js";
import { sendTo } from "../sender.js";

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
        if (account === undefined) {
            throw new CreateActorError("Usuário não está logado.");
        }

        if (validateUsername(identifier).isValid === false) {
            throw new CreateActorError("Nome do personagem inválido.");
        }

        if (sprite === undefined || sprite.trim() === "") {
            throw new CreateActorError("Sprite inválido.");
        }

        const lowerIdentifier = identifier.toLowerCase();

        const existing = await readActorByIdentifier(
            account.id,
            lowerIdentifier,
        );
        if (existing !== undefined) {
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

        sendTo(clientId, {
            id: packetId,
            data: {
                success: true,
                message: `Personagem ${lowerIdentifier} criado com sucesso!`,
            },
        });
    } catch (err) {
        if (err instanceof CreateActorError) {
            sendTo(clientId, {
                id: packetId,
                data: {
                    success: false,
                    message: err.message,
                },
            });
        }

        error(`Erro inesperado no createActor: ${err}`);
        sendTo(clientId, {
            id: packetId,
            data: {
                success: false,
                message: "Erro interno no servidor.",
            },
        });
    }
}
