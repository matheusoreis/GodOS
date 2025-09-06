import knex from "knex";

const sqlite = knex({
    client: "sqlite3",
    connection: {
        filename: process.env.SQLITE_DB_FILE ?? "./dev.sqlite3",
    },
    useNullAsDefault: true,
});

export default sqlite;
