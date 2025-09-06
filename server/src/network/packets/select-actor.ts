import { Packets } from "../handler.js";

export type SelectActorData = {
    id: number;
};

export async function selectActor(
    id: number,
    data: SelectActorData,
): Promise<void> {
    const packet: number = Packets.SelectActor;
}
