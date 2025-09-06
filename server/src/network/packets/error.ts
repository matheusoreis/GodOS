import { sendTo } from "../sender.js";

export function sendError(clientId: number, packet: number, message: string) {
    sendTo(clientId, {
        id: packet,
        data: {
            success: false,
            message: message,
        },
    });
}
