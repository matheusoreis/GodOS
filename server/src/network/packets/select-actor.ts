import type { Account } from "../../database/services/account.js";
import { getActorById, type Actor } from "../../database/services/actor.js";
import type { Map } from "../../database/services/map.js";
import { getAccount } from "../../modules/account.js";
import { setActor, getAllActorsInMap } from "../../modules/actor.js";
import { getMapById } from "../../modules/map.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendTo, sendToMapBut } from "../sender.js";
import { sendError } from "./error.js";

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
    const packetSelectActor = Packets.SelectActor;
    const packetActorsToMe = Packets.ActorsToMe;
    const PacketMeToActors = Packets.MeToActors;

    try {
        const account: Account | undefined = getAccount(clientId);
        if (account === undefined) {
            throw new SelectActorError("Usuário não está logado.");
        }

        const { actorId } = data;

        const actor: Actor | undefined = await getActorById(actorId);
        if (actor === undefined) {
            throw new SelectActorError(
                "Não foi possível encontrar o personagem.",
            );
        }

        const map: Map | undefined = getMapById(actor.mapId);
        if (map === undefined) {
            throw new SelectActorError("Não foi possível encontrar o mapa.");
        }

        const actorsInMap = getAllActorsInMap(actor.mapId);

        setActor(clientId, actor);

        sendTo(clientId, {
            id: packetSelectActor,
            data: {
                map: { id: map.id, identifier: map.identifier, file: map.file },
                actor: actor,
            },
        });

        // Envia todos os outros actors do mapa para ele
        sendTo(clientId, {
            id: packetActorsToMe,
            data: actorsInMap,
        });

        // Anuncia ele para os outros
        sendToMapBut(actor.mapId, clientId, {
            id: PacketMeToActors,
            data: actor,
        });
    } catch (err) {
        if (err instanceof SelectActorError) {
            return sendError(clientId, packetSelectActor, err.message);
        }

        error(`Erro inesperado no SelectActor: ${err}`);
        return sendError(
            clientId,
            packetSelectActor,
            "Erro interno no servidor.",
        );
    }
}
