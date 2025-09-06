import { Packets } from '../handler.js';
import { sendTo } from '../sender.js';

export async function ping(id: number, _: any): Promise<void> {
    const packet: number = Packets.Ping;

    sendTo(id, {
        packet: packet,
        data: {},
    });
}
