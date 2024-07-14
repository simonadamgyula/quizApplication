import http from "http";
import { Response } from "./response.js";
import { handleQuiz } from "./quizHandler.js";
import { authenticateUser, loginHandler, registerHandler } from "./authentication.js";

http.createServer((req, res) => {
    const url = req.url.substring(1).split("/");

    switch (url[0]) {
        case "quiz":
            handleQuiz(req, res, url);
            break;
        case "login":
            loginHandler(req, res);
            break;
        case "register":
            registerHandler(req, res);
            break;
        default:
            Response.NotFound(res).send("Not found!");
            break;
    }
}).listen(3000);

export function getBody(req) {
    return new Promise((resolve, reject) => {
        let body = "";
        req.on("data", chunk => {
            body += chunk.toString();
        });
        req.on("end", () => {
            resolve(JSON.parse(body));
        });
    });

}