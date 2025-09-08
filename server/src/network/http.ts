import { compare, hash } from "bcrypt";
import express from "express";
import { createServer } from "http";
import jwt from "jsonwebtoken";
import {
    createAccount,
    readAccountByEmail,
    readAccountByUsername,
    readAccountByUsernameOrEmail,
} from "../database/services/account.js";
import {
    validateClientVersion,
    validateEmail,
    validateIdentifier,
    validatePassword,
    validateUsername,
} from "../shared/validation.js";

const JWT_SECRET = process.env.JWT_SECRET ?? "";

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
                JWT_SECRET,
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

    app.post("/sign-up", async (req, res) => {
        try {
            const { username, email, password } = req.body;

            if (!validateUsername(username).isValid) {
                return res
                    .status(400)
                    .json({ error: "Nome de usuário inválido." });
            }
            if (!validateEmail(email).isValid) {
                return res.status(400).json({ error: "E-mail inválido." });
            }
            if (!validatePassword(password).isValid) {
                return res.status(400).json({ error: "Senha inválida." });
            }

            const lowerUsername = username.toLowerCase();
            const lowerEmail = email.toLowerCase();

            const existing =
                (await readAccountByEmail(lowerEmail)) ??
                (await readAccountByUsername(lowerUsername));

            if (existing) {
                return res.status(409).json({
                    error: "Este e-mail ou nome de usuário já está em uso.",
                });
            }

            const hashedPassword = await hash(password, 10);

            await createAccount({
                username: lowerUsername,
                email: lowerEmail,
                password: hashedPassword,
            });

            return res.status(201).json({
                message: `Seja bem-vindo ${username}, sua conta foi criada com sucesso!`,
            });
        } catch (err) {
            return res.status(500).json({ error: "Erro interno no servidor." });
        }
    });

    const server = createServer(app);
    return { app, server };
}
