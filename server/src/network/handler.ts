import type { RawData } from "ws";
import { disconnectClient, isConnected } from "../modules/client.js";
import { error, warning } from "../shared/logger.js";

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

const handlers: Record<number, PacketHandler> = {};

export async function handler(id: number, raw: RawData): Promise<void> {
    if (isConnected(id) === false) {
        return;
    }

    try {
        const parsed: Packet = JSON.parse(raw.toString());

        if (isValidPacket(parsed) == false) {
            warning(`O cliente ${id} enviou um pacote inválido!`);
            return disconnectClient(id);
        }

        const handler = handlers[parsed.packet];
        if (handler === undefined) {
            warning(`O cliente ${id} enviou um pacote desconhecido!`);
            return disconnectClient(id);
        }

        await handler(id, parsed.data);
    } catch (e) {
        error(`Erro ao processar pacote do cliente ${id}: ${e}`);
    }
}

function isValidPacket(data: Packet): boolean {
    return data?.packet !== undefined && data?.data !== undefined;
}
