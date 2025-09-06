export interface ValidationResult {
    isValid: boolean;
    error?: string;
}

export function validateEmail(email: string): ValidationResult {
    if (!email) {
        return { isValid: false, error: "E-mail é obrigatório." };
    }

    const emailLower = email.toLowerCase();

    if (!/^[\w.-]+@[\w.-]+\.\w{2,}$/.test(emailLower)) {
        return { isValid: false, error: "E-mail inválido." };
    }

    return { isValid: true };
}

export function validateUsername(user: string): ValidationResult {
    var userMinLength = Number(process.env.USER_MIN_LENGTH ?? 0);
    var userMaxLength = Number(process.env.USER_MAX_LENGTH ?? 0);

    if (!user) {
        return { isValid: false, error: "Nome de usuário é obrigatório." };
    }

    const userLower = user.toLowerCase();

    if (userLower.length < userMinLength || userLower.length > userMaxLength) {
        return {
            isValid: false,
            error: `Nome de usuário deve conter entre ${userMinLength} e ${userMaxLength} caracteres.`,
        };
    }

    if (!/^[a-z0-9]+$/.test(userLower)) {
        return {
            isValid: false,
            error: "Nome de usuário deve conter apenas letras minúsculas e números.",
        };
    }

    return { isValid: true };
}

export function validateIdentifier(identifier: string): ValidationResult {
    if (!identifier) {
        return { isValid: false, error: "E-mail ou usuário é obrigatório." };
    }

    const identifierLower = identifier.toLowerCase();

    if (identifierLower.includes("@")) {
        return validateEmail(identifier);
    } else {
        return validateUsername(identifier);
    }
}

export function validatePassword(password: string): ValidationResult {
    var passwordMinLength = Number(process.env.PASSWORD_MIN_LENGTH ?? 0);

    if (!password) {
        return { isValid: false, error: "Senha é obrigatória." };
    }

    if (password.length < passwordMinLength) {
        return {
            isValid: false,
            error: `A senha deve ter pelo menos ${passwordMinLength} caracteres.`,
        };
    }

    if (!/^(?=.*[A-Z])(?=.*\d).+$/.test(password)) {
        return {
            isValid: false,
            error: "A senha deve conter pelo menos uma letra maiúscula e um número.",
        };
    }

    return { isValid: true };
}

export function validatePasswordMatch(
    password: string,
    rePassword: string,
): ValidationResult {
    if (password !== rePassword) {
        return { isValid: false, error: "As senhas não coincidem." };
    }

    return { isValid: true };
}

export function validateClientVersion(
    major: number,
    minor: number,
    revision: number,
): ValidationResult {
    const majorVersion = Number(process.env.MAJOR_VERSION ?? 0);
    const minorVersion = Number(process.env.MINOR_VERSION ?? 0);
    const revisionVersion = Number(process.env.REVISION_VERSION ?? 0);

    if (
        major !== majorVersion ||
        minor !== minorVersion ||
        revision !== revisionVersion
    ) {
        return {
            isValid: false,
            error: `Versão do cliente incompatível. Por favor, atualize para a versão ${majorVersion}.${minorVersion}.${revisionVersion}.`,
        };
    }

    return { isValid: true };
}
