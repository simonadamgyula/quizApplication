import bcrypt from 'bcrypt';
import { register, login, authenticate, logOut } from './database.js';
import { getBody } from './index.js';
import { Response } from './response.js';


/**
 * 
 * @param {Request} req 
 * @param {*} onFail 
 * @param {*} onSuccess 
 * @returns 
 */
export function authenticateUser(req, onFail = () => { }, onSuccess = user_id => { }) {
    const authentication = req.headers.authorization || '';
    const token = authentication.split(" ").pop() || '';

    console.log(authentication);

    return new Promise((resolve, reject) => {
        authenticate(token).then(user_id => {
            onSuccess(user_id);
            resolve(user_id);
        }, () => {
            onFail();
            resolve(null);
        });
    });
}

export async function loginHandler(req, res) {
    const body = await getBody(req);
    const { username, password } = body;

    login(username, password)
        .then(result => {
            if (result) {
                Response.OK(res).send({ token: result });
            } else {
                Response.Unauthorized(res).send("Login failed");
            }
        },
            reason => {
                Response.Unauthorized(res).send("Login failed: " + reason);
            });
}

export async function registerHandler(req, res) {
    const body = await getBody(req);
    const { username, password } = body;

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    register(username, hashedPassword)
        .then(() => {
            Response.OK(res).send("User registered");
        })
        .catch((err) => {
            Response.BadRequest(res).send("Registration failed: " + err.message);
        });
}

export async function logoutHandler(req, res) {
    const authentication = req.headers.authorization || '';
    const token = authentication.split(" ").pop() || '';

    if (token === "") {
        console.log(`${token} ${token_split} ${authentication}`);
        Response.BadRequest(res).send("No token provided");
        return;
    }

    logOut(token)
        .then(() => {
            Response.OK(res).send("Logged out");
        })
        .catch((err) => {
            console.log(err);
            Response.BadRequest(res).send("Logout failed: " + err);
        })
}