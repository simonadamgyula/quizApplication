import { Response } from "./response.js";
import { getQuestions, createQuestion, editQuestion, deleteQuestion } from "./database.js";
import { authenticateUser } from "./authentication.js";

export function questionsHandler(req, res, url, body) {
    switch (url[2]) {
        case "get":
            getQuestionsHandler(req, res, body);
            break;
        case "create":
            createQuestionHandler(req, res, body);
            break;
        case "delete":
            deleteQuestionHandler(req, res, body);
            break;
        case "edit":
            editQuestionHandler(req, res, body);
            break;
        default:
            Response.NotFound(res).send("Not found");
            break;
    }
}

async function createQuestionHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { quiz_id, question, answer, options, type, index } = body;

    createQuestion(user_id, quiz_id, question, type, JSON.stringify(options), answer, index)
        .then(id => {
            Response.OK(res).send({ id });
        })
        .catch(reason => {
            Response.BadRequest(res).send("Question creation failed: " + reason);
        });
}

async function getQuestionsHandler(req, res, body) {
    const user_id = await authenticateUser(req);

    const { id } = body;

    getQuestions(id, user_id)
        .then(questions => {
            Response.OK(res).send(questions);
        });
}

async function deleteQuestionHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id } = body;
    console.log("adfsa" + id);

    deleteQuestion(user_id, id)
        .then(() => {
            Response.OK(res).send("Question deleted");
        }, reason => {
            Response.BadRequest(res).send("Question deletion failed: " + reason);
        });
}

async function editQuestionHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id, question, answer, options, type } = body;

    editQuestion(user_id, id, question, type, JSON.stringify(options), answer)
        .then(() => {
            Response.OK(res).send("Question edited");
        }, reason => {
            Response.BadRequest(res).send("Question edit failed: " + reason);
        });
}