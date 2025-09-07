export const TICKS_PER_SECOND = 60;

export const seconds = (n: number) => Math.floor(n * TICKS_PER_SECOND);
export const minutes = (n: number) => seconds(n * 60);
export const hours = (n: number) => minutes(n * 60);
export const days = (n: number) => hours(n * 24);

export function timesPerSecond(times: number) {
    return Math.floor(TICKS_PER_SECOND / times);
}

export function timesPerMinute(times: number) {
    return Math.floor(minutes(1) / times);
}

export function timesPerHour(times: number) {
    return Math.floor(hours(1) / times);
}

export function timesPerDay(times: number) {
    return Math.floor(days(1) / times);
}
