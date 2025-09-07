import { hasActorsInMap } from "./modules/actor.js";
import { getAllMaps } from "./modules/map.js";
import { timesPerSecond } from "./shared/time.js";

let tickCount = 0;

export function startLoop() {
    setInterval(gameLoop, 1000 / 60);
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
