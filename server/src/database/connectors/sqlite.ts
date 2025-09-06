import knex from "knex";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const sqlite = knex({
    client: "sqlite3",
    connection: {
        filename: path.resolve(__dirname, "../database.sqlite3"),
    },
    useNullAsDefault: true,
});

export default sqlite;
