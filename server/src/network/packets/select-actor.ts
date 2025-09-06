import { Packets } from "../handler.js";

export type SelectActorData = {
    id: number;
};

export async function handleSelectActor(
    id: number,
    data: SelectActorData,
): Promise<void> {
    const packet: number = Packets.SelectActor;
}
