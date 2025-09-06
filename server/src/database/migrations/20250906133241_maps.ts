import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
    return knex.schema.createTable("maps", (table) => {
        table.increments("id").primary();
        table.string("identifier").notNullable().unique();
        table.string("file").notNullable();
        table.timestamp("createdAt").defaultTo(knex.fn.now()).notNullable();
        table.timestamp("updatedAt").defaultTo(knex.fn.now()).notNullable();
    });
}

export async function down(knex: Knex): Promise<void> {
    return knex.schema.dropTableIfExists("maps");
}
