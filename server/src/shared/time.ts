export const TICKS_PER_SECOND = 60;

export const seconds = (n: number) => Math.floor(n * TICKS_PER_SECOND);
export const minutes = (n: number) => seconds(n * 60);
export const hours = (n: number) => minutes(n * 60);
export const days = (n: number) => hours(n * 24);

export const timesPerSecond = (times: number) =>
    Math.floor(TICKS_PER_SECOND / times);

export const timesPerMinute = (times: number) => Math.floor(minutes(1) / times);

export const timesPerHour = (times: number) => Math.floor(hours(1) / times);

export const timesPerDay = (times: number) => Math.floor(days(1) / times);
