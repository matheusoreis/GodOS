import type { Knex } from "knex";

const knexConfig: { [key: string]: Knex.Config } = {
    sqlite: {
        client: "sqlite3",
        connection: {
            filename: process.env.SQLITE_DB_FILE ?? "./dev.sqlite3",
        },
        useNullAsDefault: true,
        migrations: {
            directory: "./migrations",
            tableName: "migrations",
            extension: "ts",
        },
        seeds: {
            directory: "./seeds",
            extension: "ts",
        },
    },
    postgres: {
        client: "pg",
        connection: {
            host: process.env.POSTGRES_DB_HOST ?? "127.0.0.1",
            port: Number(process.env.POSTGRES_DB_PORT) ?? 5432,
            user: process.env.POSTGRES_DB_USER ?? "postgres",
            password: process.env.POSTGRES_DB_PASS ?? "postgres",
            database: process.env.POSTGRES_DB_NAME ?? "postgres",
        },
        searchPath: [process.env.POSTGRES_DB_SCHEMA ?? "public"],
        pool: { min: 2, max: 10 },
        migrations: {
            directory: "./migrations",
            tableName: "migrations",
            extension: "ts",
        },
        seeds: {
            directory: "./seeds",
            extension: "ts",
        },
    },
};

module.exports = knexConfig;
