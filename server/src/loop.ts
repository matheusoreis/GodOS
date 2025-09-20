import { hasActorsInMap } from "./module/actor.js";
import { getAllMaps } from "./module/map.js";
import { TICKS_PER_SECOND, timesPerSecond } from "./shared/time.js";

let tickCount = 0;
let intervalId: NodeJS.Timeout | null = null;

export function startLoop() {
    if (intervalId === null) {
        intervalId = setInterval(gameLoop, 1000 / TICKS_PER_SECOND);
    }
}

export function stopLoop() {
    if (intervalId !== null) {
        clearInterval(intervalId);
        intervalId = null;
    }
}

function gameLoop() {
    tickCount++;

    if (tickCount % timesPerSecond(2) === 0) {
        mapLoop();
    }
}

function mapLoop() {
    for (const map of getAllMaps()) {
        if (hasActorsInMap(map.id) === false) {
            continue;
        }
    }
}
