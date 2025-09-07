import { hasActorsInMap } from "./module/actor.js";
import { getAllMaps } from "./module/map.js";
import { TICKS_PER_SECOND, timesPerSecond } from "./shared/time.js";

let tickCount = 0;

export function startLoop() {
    setInterval(gameLoop, 1000 / TICKS_PER_SECOND);
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
