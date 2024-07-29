import { loginHandler, registerHandler, logoutHandler } from "./authentication.js";
import { Response } from "./response.js";
import { authenticateUser } from "./authentication.js";
import { getBody } from "./index.js";
import { getUsername } from "./database.js";

export function userHandler(req, res, url) {
    getBody(req).then(body => {
        switch (url[1]) {
            case "get_username":
                getUsernameHandler(req, res, body);
                break;
            case "login":
                loginHandler(req, res, body);
                break;
            case "register":
                registerHandler(req, res, body);
                break;
            case "logout":
                logoutHandler(req, res);
                break;
            default:
                Response.NotFound(res).send("Not found");
                break;
        }
    });
}

async function getUsernameHandler(req, res, body) {
    if (!await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    })) return;

    const { user_id } = body;

    getUsername(user_id)
        .then(username => {
            Response.OK(res).send({ username });
        })
        .catch(reason => {
            Response.BadRequest(res).send("Failed to get username: " + reason);
        });
}