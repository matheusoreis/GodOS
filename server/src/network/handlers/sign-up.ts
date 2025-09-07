import { hash } from "bcrypt";
import {
    createAccount,
    readAccountByEmail,
    readAccountByUsername,
} from "../../database/services/account.js";
import { error } from "../../shared/logger.js";
import {
    validateEmail,
    validatePassword,
    validateUsername,
} from "../../shared/validation.js";
import { Packets } from "../handler.js";
import { sendFailure, sendSuccess } from "../sender.js";

type SignUp = {
    username: string;
    email: string;
    password: string;
};

class SignUpError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "SignUpError";
    }
}

export async function handleSignUp(
    clientId: number,
    data: SignUp,
): Promise<void> {
    const packetId: number = Packets.SignUp;

    try {
        const { username, email, password } = data;

        if (!validateUsername(username).isValid) {
            throw new SignUpError("Nome de usuário inválido.");
        }

        if (!validateEmail(email).isValid) {
            throw new SignUpError("E-mail inválido.");
        }

        if (!validatePassword(password).isValid) {
            throw new SignUpError("Senha inválida.");
        }

        const lowerUsername = username.toLowerCase();
        const lowerEmail = email.toLowerCase();

        const existing =
            (await readAccountByEmail(lowerEmail)) ??
            (await readAccountByUsername(lowerUsername));

        if (existing) {
            throw new SignUpError(
                "Este e-mail ou nome de usuário já está em uso.",
            );
        }

        const hashedPassword = await hash(password, 10);

        await createAccount({
            username: lowerUsername,
            email: lowerEmail,
            password: hashedPassword,
        });

        sendSuccess(
            clientId,
            packetId,
            {},
            `Seja bem-vindo ${username}, sua conta foi criada com sucesso!`,
        );
    } catch (err) {
        if (err instanceof SignUpError) {
            return sendFailure(clientId, packetId, err.message);
        }

        error(`Erro inesperado no signUp: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
