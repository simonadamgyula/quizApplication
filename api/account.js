import bcrypt from 'bcryptjs';
import { register, login, getHashedPassword } from './database.js';


export async function login(req, res, body) {
    const { username, password } = body;

    const hash = await getHashedPassword(username);

    bcrypt.compare(password, hash)
        .then(result => {
            if (result) {
                Response.OK(res).send(JSON.stringify("Login successful"));
            } else {
                Response.Unauthorized(res).send(JSON.stringify("Login failed"));
            }
        });
}

export async function register(req, res, body) {
    const { username, password } = body;

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    register(username, hashedPassword)
        .then(() => {
            Response.OK(res).send(JSON.stringify("User registered"));
        });
}