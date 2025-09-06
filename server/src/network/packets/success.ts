import { sendTo } from "../sender.js";

export function sendSuccess(
    clientId: number,
    packet: number,
    data: Record<string, any>,
) {
    sendTo(clientId, {
        id: packet,
        data: { success: true, ...data },
    });
}
