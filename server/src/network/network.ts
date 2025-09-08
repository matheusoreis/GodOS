import type { Server } from "http";
import jwt from "jsonwebtoken";
import { WebSocket, WebSocketServer, type RawData } from "ws";
import { removeAccount } from "../module/account.js";
import { removeActor } from "../module/actor.js";
import { removeClient, setClient, type Client } from "../module/client.js";
import { info, warning } from "../shared/logger.js";
import { handler } from "./handler.js";

export function startWebSocketServer(server: Server) {
    const wss = new WebSocketServer({ noServer: true });

    server.on("upgrade", (req, socket, head) => {
        const url = new URL(req.url ?? "", "http://godos");
        const token = url.searchParams.get("token");

        if (!token) {
            socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
            socket.destroy();
            return;
        }

        try {
            const payload = jwt.verify(token, process.env.JWT_SECRET ?? "");
            (req as any).user = payload;
            wss.handleUpgrade(req, socket, head, (ws) => {
                wss.emit("connection", ws, req);
            });
        } catch {
            socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
            socket.destroy();
        }
    });

    wss.on("connection", (ws: WebSocket, req) => {
        const user = (req as any).user;

        const client: Client | undefined = setClient(ws);
        if (client === undefined) {
            warning("O servidor está cheio!");
            return ws.close();
        }

        info(`Cliente ${client.id} (${user.username}) entrou no servidor.`);

        ws.on("message", async (data: RawData, isBinary: boolean) => {
            if (isBinary) {
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

    info("Servidor WebSocket iniciado com sucesso!");
}
