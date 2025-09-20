import { WebSocket, WebSocketServer, type RawData } from "ws";
import { setClient, removeClient, type Client } from "../module/client.js";
import { info, warning } from "../shared/logger.js";
import { handler } from "./handler.js";
import { removeAccount } from "../module/account.js";
import { removeActor } from "../module/actor.js";

let wss: WebSocketServer | null = null;

export function startNetwork(port: number) {
    wss = new WebSocketServer({ port });

    wss.on("connection", (ws: WebSocket) => {
        const client: Client | undefined = setClient(ws);
        if (client === undefined) {
            warning("O servidor está cheio!");
            return ws.close();
        }

        info(`Cliente ${client.id} entrou no servidor.`);

        ws.on("message", async (data: RawData, isBinary: boolean) => {
            if (isBinary === true) {
                warning(
                    `O cliente ${client.id} enviou um pacote não suportado!`,
                );
                return ws.close();
            }

            await handler(client.id, data);
        });

        ws.on("close", async () => {
            info(`Cliente ${client.id} deixou o servidor.`);
            await removeActor(client.id);
            removeAccount(client.id);
            removeClient(client.id);
        });
    });
}

export function stopNetwork() {
    if (wss !== null) {
        wss.close(() => {
            info("Servidor WebSocket foi encerrado com sucesso.");
        });
        wss = null;
    }
}
