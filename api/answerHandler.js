import { Response } from "./response.js";
import { authenticateUser } from "./authentication.js";
import { getAnswerById, getAnswersByQuestionId, submitAnswer } from "./database.js";

export function answerHandler(req, res, url, body) {
    switch (url[2]) {
        case "get":
            getAnswer(req, res, body);
            break;
        case "get_all":
            getAllAnswers(req, res, body);
            break;
        case "create":
            submitAnswerHandler(req, res, body);
            break;
        default:
            Response.NotFound(res).send("Not found");
            break;
    }
}

/**
 * 
 * @param {Request} req 
 * @param {Response} res 
 * @param {*} body 
 * @returns 
 */
async function getAnswer(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id } = body;

    getAnswerById(id, user_id)
        .then(answer => {
            Response.OK(res).send(answer);
        });
}

/**
 * 
 * @param {Request} req 
 * @param {Response} res 
 * @param {*} body 
 * @returns 
 */
async function getAllAnswers(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { question_id } = body;

    getAnswersByQuestionId(question_id, user_id)
        .then(answers => {
            Response.OK(res).send(answers);
        });
}

/**
 * 
 * @param {Request} req 
 * @param {Response} res 
 * @param {*} body 
 * @returns 
 */
async function submitAnswerHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { question_id, answer, score_earned } = body;

    submitAnswer(user_id, question_id, answer, score_earned)
        .then(() => {
            Response.OK(res).send("Answer submitted");
        });
}