import knex from "knex";

const SQLite = knex({
    client: "sqlite3",
    connection: {
        filename: process.env.SQLITE_DB_FILE ?? "./dev.sqlite3",
    },
    useNullAsDefault: true,
});

export default SQLite;
