import { getBody } from "./index.js";
import { Response } from "./response.js";
import { getQuestions, createQuestion, editQuestion } from "./database.js";
import { authenticateUser } from "./authentication.js";

export function questionsHander(req, res, url, body) {
    console.log("handling questions");
    console.log(url[2] == "get");

    switch (url[2]) {
        case "get":
            getQuestionsHandler(req, res, body);
            break;
        case "create":
            createQuestionHandler(req, res, body);
            break;
        case "delete":
            deleteQuestion(req, res, body);
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

    const { quiz_id, question, answer, options, type } = body;

    createQuestion(user_id, quiz_id, question, type, options, answer)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Question created"));
        },
            reason => {
                Response.BadRequest(res).send(JSON.stringify("Question creation failed: " + reason));
            });
}

function getQuestionsHandler(req, res, body) {
    const { id } = body;

    getQuestions(id)
        .then(questions => {
            Response.OK(res).send(JSON.stringify(questions));
        });
}

async function deleteQuestion(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id } = body;

    deleteQuestion(user_id, id)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Question deleted"));
        }, reason => {
            Response.BadRequest(res).send(JSON.stringify("Question deletion failed: " + reason));
        });
}

async function editQuestionHandler(req, res, body) {
    const user_id = await authenticateUser(req, () => {
        Response.Unauthorized(res).send("Unauthorized");
    });
    if (!user_id) return;

    const { id, question, answer, options, type } = body;

    editQuestion(user_id, id, question, type, options, answer)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Question edited"));
        }, reason => {
            Response.BadRequest(res).send(JSON.stringify("Question edit failed: " + reason));
        });
}