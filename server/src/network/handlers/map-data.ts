import { Packets } from "../handler.js";

export async function handleMapData(clientId: number, _: any): Promise<void> {
    const packetId: number = Packets.MapData;
}
