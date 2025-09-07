import { hasPlayersInMap } from "./actor.js";
import { getAllMaps } from "./map.js";

let tickCount = 0;

export function startLoop() {
    setInterval(gameLoop, 1000 / 60);
}

function gameLoop() {
    tickCount++;

    // A cada tick (~16ms)
    if (tickCount % 1 === 0) {
    }

    // A cada 30 ticks (~500ms)
    if (tickCount % 30 === 0) {
        mapLoop();
    }

    // A cada 60 ticks (~1s)
    if (tickCount % 60 === 0) {
    }

    // A cada 300 ticks (~5s)
    if (tickCount % 300 === 0) {
    }

    // A cada 18000 ticks (~5min)
    if (tickCount % 18000 === 0) {
    }
}

export function mapLoop() {
    for (const map of getAllMaps()) {
        if (hasPlayersInMap(map.id) === false) {
            continue;
        }
    }
}
