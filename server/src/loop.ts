import { hasActorsInMap } from "./modules/actor.js";
import { getAllMaps } from "./modules/map.js";

type LoopHandler = {
    interval: number;
    callback: (tick: number) => void;
};

let tickCount = 0;

function mapLoop() {
    for (const map of getAllMaps()) {
        if (hasActorsInMap(map.id) === false) {
            continue;
        }
    }
}

const handlers: LoopHandler[] = [{ interval: 30, callback: mapLoop }];

export function startLoop() {
    setInterval(gameLoop, 1000 / 60);
}

function gameLoop() {
    tickCount++;
    for (const { interval, callback } of handlers) {
        if (tickCount % interval === 0) {
            callback(tickCount);
        }
    }
}
