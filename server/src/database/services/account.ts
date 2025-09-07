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

async function getById(accountId: number): Promise<Account | undefined> {
    return await sqlite<Account>("accounts").where({ id: accountId }).first();
}

async function getAll(): Promise<Account[]> {
    return await sqlite<Account>("accounts")
        .select("*")
        .orderBy("createdAt", "desc");
}

async function getByEmail(email: string): Promise<Account | undefined> {
    return await sqlite<Account>("accounts")
        .select("*")
        .where("email", email)
        .first();
}

async function getByUsername(username: string): Promise<Account | undefined> {
    return await sqlite<Account>("accounts")
        .select("*")
        .where("username", username)
        .first();
}

async function getByUsernameOrEmail(
    identifier: string,
): Promise<Account | undefined> {
    return await sqlite<Account>("accounts")
        .where("username", identifier)
        .orWhere("email", identifier)
        .first();
}

async function create(data: CreateAccount): Promise<void> {
    const { username, email, password } = data;

    await sqlite<Account>("accounts").insert({
        username,
        email,
        password: password,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
}

async function updateById(
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

export const accountDatabase = {
    getById,
    getAll,
    getByEmail,
    getByUsername,
    getByUsernameOrEmail,
    create,
    updateById,
};
