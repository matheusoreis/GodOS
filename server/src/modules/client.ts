import { WebSocket } from "ws";

export type Client = {
    id: number;
    socket: WebSocket;
};

export const clients: Array<Client | undefined> = Array(
    Number(process.env.CAPACITY ?? 0),
).fill(undefined);

export function addClient(socket: WebSocket): Client | undefined {
    const id = clients.findIndex((c) => c === undefined);
    if (id === -1) {
        return undefined;
    }

    const client: Client = {
        id: id,
        socket: socket,
    };

    clients[id] = client;

    return client;
}

export function getClient(clientId: number): Client | undefined {
    return clients[clientId];
}

export function getAllClients(): Client[] {
    return clients.filter(function (client): client is Client {
        return client !== undefined;
    });
}

export function removeClient(clientId: number): void {
    if (clientId >= 0 && clientId < clients.length) {
        clients[clientId] = undefined;
    }
}

export function isConnected(clientId: number): boolean {
    const client = getClient(clientId);
    return client !== undefined && client.socket.readyState === WebSocket.OPEN;
}

export function disconnectClient(id: number): void {
    if (isConnected(id) === false) {
        return;
    }

    const client = getClient(id)!;
    client.socket.close();
}
