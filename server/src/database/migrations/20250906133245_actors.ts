import type { Knex } from "knex";

export async function up(knex: Knex): Promise<void> {
    return knex.schema.createTable("actors", (table) => {
        table.increments("id").primary();
        table.string("identifier").notNullable().unique();
        table.string("sprite").notNullable();
        table.integer("positionX").notNullable();
        table.integer("positionY").notNullable();
        table.integer("directionX").notNullable();
        table.integer("directionY").notNullable();
        table.timestamp("createdAt").defaultTo(knex.fn.now()).notNullable();
        table.timestamp("updatedAt").defaultTo(knex.fn.now()).notNullable();
        table
            .integer("accountId")
            .unsigned()
            .notNullable()
            .references("id")
            .inTable("accounts")
            .onDelete("CASCADE");
        table
            .integer("mapId")
            .unsigned()
            .notNullable()
            .references("id")
            .inTable("maps")
            .onDelete("CASCADE");
    });
}

export async function down(knex: Knex): Promise<void> {
    return knex.schema.dropTableIfExists("actors");
}
