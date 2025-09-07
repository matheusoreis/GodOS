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
import { sendTo } from "../sender.js";

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

        if (validateClientVersion(major, minor, revision).isValid === false) {
            throw new SignInError("Versão do cliente inválida.");
        }

        if (validateIdentifier(identifier).isValid === false) {
            throw new SignInError("Identificador inválido.");
        }

        if (validatePassword(password).isValid === false) {
            throw new SignInError("Senha inválida.");
        }

        const lowerIdentifier = identifier.toLowerCase();

        const account = await readAccountByUsernameOrEmail(lowerIdentifier);
        if (account === undefined) {
            throw new SignInError("Usuário ou e-mail não encontrado.");
        }

        const isPasswordValid = await compare(password, account.password);
        if (isPasswordValid === false) {
            throw new SignInError("A senha informada está incorreta.");
        }

        setAccount(clientId, account);

        sendTo(clientId, {
            id: packetId,
            data: {
                success: true,
                message: `Bem-vindo ${account.username} ao ${process.env.SERVER_NAME}! Leia as regras!`,
                account: account,
            },
        });
    } catch (err) {
        if (err instanceof SignInError) {
            sendTo(clientId, {
                id: packetId,
                data: {
                    success: false,
                    message: err.message,
                },
            });

            return;
        }

        error(`Erro inesperado no signIn: ${err}`);
        sendTo(clientId, {
            id: packetId,
            data: {
                success: false,
                message: "Erro interno no servidor.",
            },
        });
    }
}
