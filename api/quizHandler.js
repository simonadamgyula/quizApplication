import { Response } from "./response.js";
import { getBody } from "./index.js";
import { createQuiz, getQuizByCode, getQuizById, getQuizzes, deleteQuiz, editQuiz, setMaxScore } from "./database.js";
import { questionsHandler } from "./questionsHandler.js";
import { authenticateUser } from "./authentication.js";
import { answerHandler } from "./answerHandler.js";

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
                case "set_max_score":
                    setMaxScoreHandler(req, res, body);
                    break;
                case "delete":
                    deleteQuizHandler(req, res, body);
                    break;
                case "get":
                    getQuiz(req, res, body);
                    break;
                case "get_all":
                    getAllQuizzes(req, res, body);
                    break;
                case "get_owned":
                    getOwnedQuiz(req, res, body);
                    break;
                case "questions":
                    questionsHandler(req, res, url, body);
                    break;
                case "answers":
                    answerHandler(req, res, url, body);
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

async function getAllQuizzes(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    getQuizzes(user_id)
        .then(quizzes => {
            Response.OK(res).send(quizzes);
        });
}

async function setMaxScoreHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id, max_score } = body;

    setMaxScore(user_id, id, max_score)
        .then(() => {
            Response.OK(res).send("Max score set");
        })
}

async function getOwnedQuiz(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id } = body;

    getQuizById(id, user_id)
        .then(quiz => {
            Response.OK(res).send(quiz);
        });
}

async function getQuiz(req, res, body) {
    if (!await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    })) return;

    const { code } = body;

    getQuizByCode(code)
        .then(quiz => {
            Response.OK(res).send(quiz);
        })
        .catch(() => {
            Response.NotFound(res).send("Quiz not found");
        });
}

async function newQuiz(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { name, description, color } = body;

    const code = Math.random().toString().substring(2, 10);

    createQuiz(name, description, user_id, code, color)
        .then(id => {
            Response.OK(res).send({ id });
        });
}

async function editQuizHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id, name, description } = body;

    editQuiz(user_id, id, name, description)
        .then(() => {
            Response.OK(res).send("Quiz edited");
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
            Response.OK(res).send("Quiz deleted");
        });
}