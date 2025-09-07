import { hash } from "bcrypt";
import sqlite from "../connectors/sqlite.js";

export type Account = {
    id: number;
    username: string;
    email: string;
    password: string;
    maxActors: number;
    createdAt: Date;
    updatedAt: Date;
};

export type CreateAccount = {
    username: string;
    email: string;
    password: string;
};

export type UpdateAccount = {
    username?: string;
    email?: string;
    password?: string;
};

export async function readAccountById(
    accountId: number,
): Promise<Account | undefined> {
    return await sqlite<Account>("accounts").where({ id: accountId }).first();
}

export async function readAllAccounts(): Promise<Account[]> {
    return await sqlite<Account>("accounts")
        .select("*")
        .orderBy("createdAt", "desc");
}

export async function readAccountByEmail(
    email: string,
): Promise<Account | undefined> {
    return await sqlite<Account>("accounts")
        .select("*")
        .where("email", email)
        .first();
}

export async function readAccountByUsername(
    username: string,
): Promise<Account | undefined> {
    return await sqlite<Account>("accounts")
        .select("*")
        .where("username", username)
        .first();
}

export async function readAccountByUsernameOrEmail(
    identifier: string,
): Promise<Account | undefined> {
    return await sqlite<Account>("accounts")
        .where("username", identifier)
        .orWhere("email", identifier)
        .first();
}

export async function createAccount(data: CreateAccount): Promise<void> {
    const { username, email, password } = data;

    await sqlite<Account>("accounts").insert({
        username,
        email,
        password: password,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

export async function updateAccountById(
    accountId: number,
    data: UpdateAccount,
): Promise<void> {
    const { password, ...rest } = data;

    const updates: Partial<Account> = {
        ...rest,
        updatedAt: new Date(),
    };

    if (password) {
        updates.password = await hash(password, 10);
    }

    await sqlite<Account>("accounts").where({ id: accountId }).update(updates);
}
