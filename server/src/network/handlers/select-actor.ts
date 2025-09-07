import { readActorById } from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { getAllActorsInMap, setActor } from "../../module/actor.js";
import { getMapById } from "../../module/map.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendTo, sendToMapBut } from "../sender.js";

export type SelectActorData = {
    actorId: number;
};

export class SelectActorError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "SelectActorError";
    }
}

export async function handleSelectActor(
    clientId: number,
    data: SelectActorData,
): Promise<void> {
    const packetId = Packets.SelectActor;
    const packetActorsToMeId = Packets.ActorsToMe;
    const PacketMeToActorsId = Packets.MeToActors;

    try {
        const account = getAccount(clientId);
        if (account === undefined) {
            throw new SelectActorError("Usuário não está logado.");
        }

        const { actorId } = data;

        const actor = await readActorById(actorId);
        if (actor === undefined) {
            throw new SelectActorError(
                "Não foi possível encontrar o personagem.",
            );
        }

        const map = getMapById(actor.mapId);
        if (map === undefined) {
            throw new SelectActorError("Não foi possível encontrar o mapa.");
        }

        const actorsInMap = getAllActorsInMap(actor.mapId);

        setActor(clientId, actor);

        sendTo(clientId, {
            id: packetId,
            data: {
                success: true,
                map: { id: map.id, identifier: map.identifier, file: map.file },
                actor: actor,
            },
        });

        // Envia todos os outros actors do mapa para ele
        sendTo(clientId, {
            id: packetActorsToMeId,
            data: actorsInMap,
        });

        // Anuncia ele para os outros
        sendToMapBut(actor.mapId, clientId, {
            id: PacketMeToActorsId,
            data: actor,
        });
    } catch (err) {
        if (err instanceof SelectActorError) {
            sendTo(clientId, {
                id: packetId,
                data: {
                    success: false,
                    message: err.message,
                },
            });

            return;
        }

        error(`Erro inesperado no deleteActor: ${err}`);
        sendTo(clientId, {
            id: packetId,
            data: {
                success: false,
                message: "Erro interno no servidor.",
            },
        });
    }
}
