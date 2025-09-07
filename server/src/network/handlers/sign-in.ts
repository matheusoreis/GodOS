import { compare } from "bcrypt";
import { readAccountByUsernameOrEmail } from "../../database/services/account.js";
import { setAccount } from "../../module/account.js";
import { error } from "../../shared/logger.js";
import {
    validateClientVersion,
    validateIdentifier,
    validatePassword,
} from "../../shared/validation.js";
import { Packets } from "../handler.js";
import { sendFailure, sendSuccess } from "../sender.js";

type SignIn = {
    identifier: string;
    password: string;
    major: number;
    minor: number;
    revision: number;
};

class SignInError extends Error {
    constructor(message: string) {
        super(message);
        this.name = "SignInError";
    }
}

export async function handleSignIn(
    clientId: number,
    data: SignIn,
): Promise<void> {
    const packetId: number = Packets.SignIn;

    try {
        const { identifier, password, major, minor, revision } = data;

        if (!validateClientVersion(major, minor, revision).isValid) {
            throw new SignInError("Versão do cliente inválida.");
        }
        if (!validateIdentifier(identifier).isValid) {
            throw new SignInError("Identificador inválido.");
        }
        if (!validatePassword(password).isValid) {
            throw new SignInError("Senha inválida.");
        }

        const account = await readAccountByUsernameOrEmail(
            identifier.toLowerCase(),
        );
        if (!account) {
            throw new SignInError("Usuário ou e-mail não encontrado.");
        }

        const isPasswordValid = await compare(password, account.password);
        if (!isPasswordValid) {
            throw new SignInError("A senha informada está incorreta.");
        }

        setAccount(clientId, account);

        sendSuccess(
            clientId,
            packetId,
            { account },
            `Bem-vindo ${account.username} ao ${process.env.SERVER_NAME}! Leia as regras!`,
        );
    } catch (err) {
        if (err instanceof SignInError) {
            return sendFailure(clientId, packetId, err.message);
        }

        error(`Erro inesperado no signIn: ${err}`);
        sendFailure(clientId, packetId, "Erro interno no servidor.");
    }
}
