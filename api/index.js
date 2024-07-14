import http from "http";
import { Response } from "./response.js";
import { handleQuiz } from "./quizHandler.js";
import { login, register } from "./account.js";

http.createServer((req, res) => {
    const url = req.url.substring(1).split("/");
    console.log(url);

    switch (url[0]) {
        case "quiz":
            handleQuiz(req, res, url);
            break;
        case "login":
            login(req, res, body);
            break;
        case "register":
            register(req, res, body);
            break;
        default:
            Response.NotFound(res).send("Not found");
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