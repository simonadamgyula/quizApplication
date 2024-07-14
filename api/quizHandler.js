import { Response } from "./response.js";
import { getBody } from "./index.js";
import { createQuiz } from "./database.js";

export function handleQuiz(req, res) {
    console.log("quiz handler" + req.method + req.url);
    if (req.method === "POST") {
        getBody(req).then(body => {
            switch (req.url) {
                case "/quiz/new":
                    console.log("new quiz");
                    newQuiz(req, res, body);
                    break;
                default:
                    Response.NotFound(res).send("Not found");
                    break;
            }
        });
    } else if (req.method === "GET") {
        Response.NotFound(res).send("Not found");
    }
}

function newQuiz(req, res, body) {
    const { name } = JSON.parse(body);

    const code = Math.random().toString(36).substring(7);
    console.log(code);

    createQuiz(name, "abc", code)
        .then(quizId => {
            Response.OK(res).send(JSON.stringify({ id: quizId }));
        });
}