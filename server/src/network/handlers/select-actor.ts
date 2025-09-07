import { readActorById } from "../../database/services/actor.js";
import { getAccount } from "../../module/account.js";
import { getAllActorsInMap, setActor } from "../../module/actor.js";
import { getMapById } from "../../module/map.js";
import { error } from "../../shared/logger.js";
import { Packets } from "../handler.js";
import { sendFailure, sendSuccess, sendToMapBut } from "../sender.js";

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
    const packetMapDataId = Packets.MapData;
    const packetMeToActorsId = Packets.MeToActors;

    try {
        const account = getAccount(clientId);
        if (!account) {
            throw new SelectActorError("Usuário não está logado.");
        }

        const { actorId } = data;
        const actor = await readActorById(actorId);
        if (!actor) {
            throw new SelectActorError(
                "Não foi possível encontrar o personagem.",
            );
        }

        const map = getMapById(actor.mapId);
        if (!map) {
            throw new SelectActorError("Não foi possível encontrar o mapa.");
        }

        const actorsInMap = getAllActorsInMap(actor.mapId);

        // define o ator selecionado na memória do runtime
        setActor(clientId, actor);

        // pacote de confirmação da seleção
        sendSuccess(
            clientId,
            packetId,
            {},
            `Acessando o jogo com o personagem ${actor.identifier}...`,
        );

        // pacote dos dados do mapa
        sendSuccess(clientId, packetMapDataId, {
            map: map,
            actor: actor,
            actors: actorsInMap,
            npcs: [],
            items: [],
        });

        // anuncia o novo personagem para os outros personagens do mapa
        sendToMapBut(actor.mapId, clientId, {
            id: packetMeToActorsId,
            data: actor,
        });
    } catch (err) {
        if (err instanceof SelectActorError) {
            return sendFailure(clientId, packetId, err.message);
        }

        error(`Erro inesperado no selectActor: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
