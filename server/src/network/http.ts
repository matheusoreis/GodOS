import { compare } from "bcrypt";
import express from "express";
import { createServer } from "http";
import jwt from "jsonwebtoken";
import { readAccountByUsernameOrEmail } from "../database/services/account.js";
import {
    validateClientVersion,
    validateIdentifier,
    validatePassword,
} from "../shared/validation.js";

export function startHttpServer() {
    const app = express();

    app.use(express.json());

    app.post("/sign-in", async (req, res) => {
        try {
            const { identifier, password, major, minor, revision } = req.body;

            if (!validateClientVersion(major, minor, revision).isValid) {
                return res
                    .status(400)
                    .json({ error: "Versão do cliente inválida." });
            }
            if (!validateIdentifier(identifier).isValid) {
                return res
                    .status(400)
                    .json({ error: "Identificador inválido." });
            }
            if (!validatePassword(password).isValid) {
                return res.status(400).json({ error: "Senha inválida." });
            }

            const account = await readAccountByUsernameOrEmail(
                identifier.toLowerCase(),
            );
            if (!account) {
                return res
                    .status(404)
                    .json({ error: "Usuário ou e-mail não encontrado." });
            }

            const isPasswordValid = await compare(password, account.password);
            if (!isPasswordValid) {
                return res.status(401).json({ error: "Senha incorreta." });
            }

            const token = jwt.sign(
                { accountId: account.id, username: account.username },
                process.env.JWT_SECRET ?? "",
                { expiresIn: "1h" },
            );

            return res.json({
                token,
                account: { id: account.id, username: account.username },
            });
        } catch (err) {
            return res.status(500).json({ error: "Erro interno no servidor." });
        }
    });

    app.post("/sign-up", (req, res) => {});

    const server = createServer(app);
    return server;
}
