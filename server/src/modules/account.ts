export type Account = {
    id: number;
    username: string;
    email: string;
    password: string;
    createdAt: Date;
    updatedAt: Date;
};

export const accounts: Array<Account | undefined> = Array(
    Number(process.env.CAPACITY ?? 0),
).fill(undefined);

export function addAccount(id: number, account: Account): void {
    accounts[id] = account;
}

export function getAccount(id: number): Account | undefined {
    return accounts[id];
}

export function getAllAccounts(): Account[] {
    return accounts.filter(function (account): account is Account {
        return account !== undefined;
    });
}

export function removeAccount(id: number): void {
    accounts[id] = undefined;
}

export function updateAccount(id: number, data: Partial<Account>) {
    const account = getAccount(id);
    if (!account) {
        return undefined;
    }

    const updatedAccount: Account = {
        ...account,
        ...data,
        updatedAt: new Date(),
    };

    accounts[id] = updatedAccount;
    return updatedAccount;
}
