import { startLoop } from "./loop.js";
import { loadMaps } from "./module/map.js";
import { startHttpServer } from "./network/http.js";
import { startWebSocketServer } from "./network/network.js";
import { error, info, warning } from "./shared/logger.js";

async function main() {
    try {
        const port = Number(process.env.PORT ?? 7001);
        const capacity = Number(process.env.CAPACITY ?? 0);

        info("Carregando dados do jogo...");
        await loadMaps();

        info("Iniciando o loop...");
        startLoop();

        info("Iniciando o servidor HTTP...");
        const { app, server } = startHttpServer();
        server.listen(port, () => {
            info(`Servidor HTTP ouvindo na porta ${port}`);

            app.router.stack.forEach(function (r: any) {
                if (r.route && r.route.path) {
                    const methods = Object.keys(r.route.methods)
                        .map((m) => m.toUpperCase())
                        .join(", ");
                    info(`Rota HTTP registrada: [${methods}] ${r.route.path}`);
                }
            });
        });

        info("Iniciando servidor WebSocket...");
        startWebSocketServer(server);

        info(`Capacidade máxima: ${capacity} clientes`);

        process.on("SIGINT", () => {
            warning("Desligando servidor...");
            process.exit(0);
        });
    } catch (e) {
        error(`Erro ao iniciar servidor: ${e}`);
        process.exit(1);
    }
}

await main();
