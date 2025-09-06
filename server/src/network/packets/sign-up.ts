import { hash } from "bcrypt";
import {
    createAccount,
    getAccountByEmail,
    getAccountByUsername,
} from "../../database/services/account.js";
import { error } from "../../shared/logger.js";
import {
    validateEmail,
    validatePassword,
    validateUsername,
} from "../../shared/validation.js";
import { Packets } from "../handler.js";
import { sendError } from "./error.js";
import { sendSuccess } from "./success.js";

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
    const packet: number = Packets.SignUp;

    try {
        const { username, email, password } = data;

        if (validateUsername(username).isValid === false) {
            throw new SignUpError("Nome de usuário inválido.");
        }

        if (validateEmail(email).isValid === false) {
            throw new SignUpError("E-mail inválido.");
        }

        if (validatePassword(password).isValid === false) {
            throw new SignUpError("Senha inválida.");
        }

        const lowerUsername = username.toLowerCase();
        const lowerEmail = email.toLowerCase();

        const existing =
            (await getAccountByEmail(lowerEmail)) ??
            (await getAccountByUsername(lowerUsername));

        if (existing !== undefined) {
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

        return sendSuccess(clientId, packet, {
            message: "Conta criada com sucesso!",
        });
    } catch (err) {
        if (err instanceof SignUpError) {
            return sendError(clientId, packet, err.message);
        }

        error(`Erro inesperado no signUp: ${err}`);
        return sendError(clientId, packet, "Erro interno do servidor.");
    }
}
