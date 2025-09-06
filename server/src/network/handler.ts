import type { RawData } from "ws";
import { disconnectClient, isConnected } from "../modules/client.js";
import { error, warning } from "../shared/logger.js";
import { handlePing } from "./packets/ping.js";
import { handleSignIn } from "./packets/sign-in.js";
import { handleSignUp } from "./packets/sign-up.js";
import { handleActorList } from "./packets/actor-list.js";
import { handleCreateActor } from "./packets/create-actor.js";
import { handleDeleteActor } from "./packets/delete-actor.js";
import { handleSelectActor } from "./packets/select-actor.js";

export enum Packets {
    Ping,

    SignIn,
    SignUp,

    ActorList,
    CreateActor,
    DeleteActor,
    SelectActor,
}

export type Packet = {
    packet: number;
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
};

export async function handler(clientId: number, raw: RawData): Promise<void> {
    if (isConnected(clientId) === false) {
        return;
    }

    try {
        const parsed: Packet = JSON.parse(raw.toString());

        if (isValidPacket(parsed) == false) {
            warning(`O cliente ${clientId} enviou um pacote inválido!`);
            return disconnectClient(clientId);
        }

        const handler = handlers[parsed.packet];
        if (handler === undefined) {
            warning(`O cliente ${clientId} enviou um pacote desconhecido!`);
            return disconnectClient(clientId);
        }

        await handler(clientId, parsed.data);
    } catch (e) {
        error(`Erro ao processar pacote do cliente ${clientId}: ${e}`);
    }
}

function isValidPacket(data: Packet): boolean {
    return data?.packet !== undefined && data?.data !== undefined;
}
