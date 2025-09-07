import type { Account } from "../database/services/account.js";

const accounts = new Map<number, Account>();

export function setAccount(clientId: number, account: Account): void {
    accounts.set(clientId, account);
}

export function getAccount(clientId: number): Account | undefined {
    return accounts.get(clientId);
}

export function getAllAccounts(): Account[] {
    return Array.from(accounts.values());
}

export function removeAccount(clientId: number): void {
    accounts.delete(clientId);
}

export function patchAccount(
    clientId: number,
    data: Partial<Account>,
): Account | undefined {
    const account = accounts.get(clientId);
    if (!account) return undefined;

    const updated: Account = {
        ...account,
        ...data,
        updatedAt: new Date(),
    };

    accounts.set(clientId, updated);
    return updated;
}
