import { getActor } from "../modules/actor.js";
import { getAllClients, isConnected, type Client } from "../modules/client.js";
import type { Packet } from "./handler.js";

type ClientFilter = (client: Client) => boolean;

function _send(filter: ClientFilter, packet: Packet): void {
    const clients = getAllClients();
    if (clients.length === 0) {
        return;
    }

    const message = JSON.stringify(packet);

    for (const client of clients) {
        if (!filter(client)) {
            continue;
        }

        if (!isConnected(client.id)) {
            continue;
        }

        client.socket.send(message);
    }
}

export function sendTo(clientId: number, packet: Packet): void {
    _send((client) => client.id === clientId, packet);
}

export function sendToAll(packet: Packet): void {
    _send(() => true, packet);
}

export function sendToAllBut(excludeClientId: number, packet: Packet): void {
    _send((client) => client.id !== excludeClientId, packet);
}

export function sendToClients(clientIds: number[], packet: Packet): void {
    _send((client) => clientIds.includes(client.id), packet);
}
