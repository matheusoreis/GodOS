function colorText(text: string, colorCode: number): string {
    return `\x1b[${colorCode}m${text}\x1b[0m`;
}

function log(level: string, color: number, message: string): void {
    console.log(
        `${colorText(
            `[${level}]`,
            color,
        )} ${new Date().toISOString()} - ${colorText(message, color)}`,
    );
}

export function info(message: string): void {
    log("INFO", 32, message);
}

export function warning(message: string): void {
    log("WARN", 33, message);
}

export function player(message: string): void {
    log("PLAYER", 34, message);
}

export function error(message: string): void {
    log("ERROR", 31, message);
}
