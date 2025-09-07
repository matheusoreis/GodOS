import { WebSocket, WebSocketServer, type RawData } from "ws";
import { setClient, removeClient, type Client } from "../modules/client.js";
import { info, warning } from "../shared/logger.js";
import { handler } from "./handler.js";
import { removeAccount } from "../modules/account.js";
import { removeActor } from "../modules/actor.js";

/**
 * Inicia o servidor WebSocket.
 *
 * @param {number} port - A porta na qual o servidor WebSocket deve escutar.
 */
export function start(port: number) {
    const wss = new WebSocketServer({ port: port });

    // Evento disparado quando um cliente se conecta
    wss.on("connection", (ws: WebSocket) => {
        // Adiciona um novo cliente no servidor e obtem o id do mesmo.
        const client: Client | undefined = setClient(ws);
        if (client === undefined) {
            warning("O servidor está cheio!");
            return ws.close();
        }

        info(`Cliente ${client.id} entrou no servidor.`);

        // Evento disparado quando o cliente envia uma mensagem
        ws.on("message", async (data: RawData, isBinary: boolean) => {
            if (isBinary === true) {
                warning(
                    `O cliente ${client.id} enviou um pacote não suportado!`,
                );

                return ws.close();
            }

            await handler(client.id, data);
        });

        // Evento disparado quando o cliente encerra a conexão
        ws.on("close", async () => {
            info(`Cliente ${client.id} deixou o servidor.`);

            removeActor(client.id);
            removeAccount(client.id);
            removeClient(client.id);
        });
    });
}
