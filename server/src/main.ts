import { startLoop, stopLoop } from "./loop.js";
import { loadMaps } from "./module/map.js";
import { startNetwork, stopNetwork } from "./network/network.js";
import { error, info, warning } from "./shared/logger.js";

async function main() {
    try {
        const port = Number(process.env.PORT ?? 7001);
        const capacity = Number(process.env.CAPACITY ?? 0);

        info("Carregando dados do jogo...");
        await loadMaps();

        info("Iniciando o loop...");
        startLoop();

        info("Iniciando servidor...");
        startNetwork(port);

        info(`Servidor rodando em ws://localhost:${port}`);
        info(`Capacidade máxima: ${capacity} clientes`);

        process.on("SIGINT", () => {
            warning("Desligando servidor...");

            process.exit(0);
        });
    } catch (e) {
        error(`Erro ao iniciar servidor: ${e}`);

        stopLoop();
        stopNetwork();

        process.exit(1);
    }
}

await main();
