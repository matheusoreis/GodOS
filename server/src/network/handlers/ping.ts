import { Packets } from "../handler.js";
import { sendTo } from "../sender.js";

export async function handlePing(clientId: number, _: any): Promise<void> {
    const packetId: number = Packets.Ping;

    sendTo(clientId, {
        id: packetId,
        data: {},
    });
}
