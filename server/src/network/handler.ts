import type { RawData } from "ws";
import { disconnectClient, isClientConnected } from "../module/client.js";
import { error, warning } from "../shared/logger.js";
import { handlePing } from "./packets/ping.js";
import { handleSignIn } from "./packets/sign-in.js";
import { handleSignUp } from "./packets/sign-up.js";
import { handleActorList } from "./packets/actor-list.js";
import { handleCreateActor } from "./packets/create-actor.js";
import { handleDeleteActor } from "./packets/delete-actor.js";
import { handleSelectActor } from "./packets/select-actor.js";
import { handleMoveActor } from "./packets/move-actor.js";

export enum Packets {
    Ping,

    SignIn,
    SignUp,

    ActorList,
    CreateActor,
    DeleteActor,
    SelectActor,

    ActorsToMe,
    MeToActors,

    MapData,

    MoveActor,
    WarpActor,

    Disconnect,
}

export type Packet = {
    id: number;
    data: Record<string, any>;
};

type PacketHandler<T = any> = (id: number, data: T) => Promise<void>;

const handlers: Record<number, PacketHandler> = {
    [Packets.Ping]: handlePing,
    [Packets.SignIn]: handleSignIn,
    [Packets.SignUp]: handleSignUp,
    [Packets.ActorList]: handleActorList,
    [Packets.CreateActor]: handleCreateActor,
    [Packets.DeleteActor]: handleDeleteActor,
    [Packets.SelectActor]: handleSelectActor,
    [Packets.MoveActor]: handleMoveActor,
};

/**
 * Processa uma mensagem recebida de um cliente.
 *
 * @param clientId Id do cliente remetente.
 * @param raw Dados crus recebidos do WebSocket.
 */
export async function handler(clientId: number, raw: RawData): Promise<void> {
    if (isClientConnected(clientId) === false) {
        return;
    }

    try {
        const parsed: Packet = JSON.parse(raw.toString());

        // Valida se o pacote é válido.
        if (isValidPacket(parsed) == false) {
            warning(`O cliente ${clientId} enviou um pacote inválido!`);
            return disconnectClient(clientId);
        }

        // Valida se o pacote tem um handler registrado
        const handler = handlers[parsed.id];
        if (handler === undefined) {
            warning(`O cliente ${clientId} enviou um pacote desconhecido!`);
            return disconnectClient(clientId);
        }

        //
        await handler(clientId, parsed.data);
    } catch (e) {
        error(`Erro ao processar pacote do cliente ${clientId}: ${e}`);
    }
}

function isValidPacket(data: Packet): boolean {
    return data?.id !== undefined && data?.data !== undefined;
}
