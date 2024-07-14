import { Response } from "./response.js";
import { getBody } from "./index.js";
import { createQuiz, getQuizByCode } from "./database.js";
import { questionsHander } from "./questionsHandler.js";

export function handleQuiz(req, res, url) {
    if (req.method === "POST") {
        getBody(req).then(body => {
            switch (url[1]) {
                case "new":
                    newQuiz(req, res, body);
                    break;
                case "get":
                    getQuiz(req, res, body);
                    break;
                case "questions":
                    questionsHander(req, res, url, body);
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

function getQuiz(req, res, body) {
    const { code } = body;

    getQuizByCode(code)
        .then(quiz => {
            Response.OK(res).send(JSON.stringify(quiz));
        });
}

function newQuiz(req, res, body) {
    const { name } = body;

    const code = Math.random().toString().substring(2, 10);

    createQuiz(name, "abc", code)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Quiz created"));
        });
}