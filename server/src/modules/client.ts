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

export function getClient(id: number): Client | undefined {
    return clients[id];
}

export function getAllClients(): Client[] {
    return clients.filter(function (client): client is Client {
        return client !== undefined;
    });
}

export function removeClient(id: number): void {
    if (id >= 0 && id < clients.length) {
        clients[id] = undefined;
    }
}

export function isConnected(id: number): boolean {
    const client = getClient(id);
    return client !== undefined && client.socket.readyState === WebSocket.OPEN;
}

export function disconnectClient(id: number): void {
    if (isConnected(id) === false) {
        return;
    }

    const client = getClient(id)!;
    client.socket.close();
}
