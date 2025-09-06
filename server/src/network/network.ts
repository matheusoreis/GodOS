import { WebSocket, WebSocketServer, type RawData } from "ws";
import { addClient, removeClient, type Client } from "../modules/client.js";
import { info, warning } from "../shared/logger.js";
import { handler } from "./handler.js";

export function start(port: number) {
    const wss = new WebSocketServer({ port: port });

    wss.on("connection", (ws: WebSocket) => {
        const client: Client | undefined = addClient(ws);
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
            removeClient(client.id);
        });
    });
}
