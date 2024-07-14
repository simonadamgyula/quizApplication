import { Response } from "./response.js";
import { getBody } from "./index.js";
import { createQuiz, getQuizByCode } from "./database.js";
import { questionsHander } from "./questionsHandler.js";
import { authenticateUser } from "./authentication.js";
import { answersHandler } from "./answersHandler.js";

export function handleQuiz(req, res, url) {
    if (req.method === "POST") {
        getBody(req).then(body => {
            switch (url[1]) {
                case "new":
                    newQuiz(req, res, body);
                    break;
                case "edit":
                    editQuizHandler(req, res, body);
                    break;
                case "delete":
                    deleteQuizHandler(req, res, body);
                    break;
                case "get":
                    getQuiz(req, res, body);
                    break;
                case "questions":
                    questionsHander(req, res, url, body);
                    break;
                case "answers":
                    answersHandler(req, res, url, body);
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

async function getQuiz(req, res, body) {
    if (!await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    })) return;

    const { code } = body;

    getQuizByCode(code)
        .then(quiz => {
            Response.OK(res).send(JSON.stringify(quiz));
        });
}

async function newQuiz(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { name } = body;

    const code = Math.random().toString().substring(2, 10);

    createQuiz(name, user_id, code)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Quiz created"));
        });
}

async function editQuizHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id, name } = body;

    editQuiz(user_id, id, name)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Quiz edited"));
        });
}

async function deleteQuizHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id } = body;

    deleteQuiz(user_id, id)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Quiz deleted"));
        });
}