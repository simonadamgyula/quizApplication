import { getBody } from "./index.js";
import { Response } from "./response.js";
import { getQuestions, createQuestion } from "./database.js";

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
        default:
            Response.NotFound(res).send("Not found");
            break;
    }

}

function createQuestionHandler(req, res, body) {
    const { quiz_id, question, answer, options, type } = body;

    createQuestion(quiz_id, question, type, options, answer)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Question created"));
        });
}

function getQuestionsHandler(req, res, body) {
    const { id } = body;

    getQuestions(id)
        .then(questions => {
            Response.OK(res).send(JSON.stringify(questions));
        });
}

function deleteQuestion(req, res, body) {
    const { id } = body;

    deleteQuestion(id)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Question deleted"));
        });
}

function editQuestion(req, res, body) {
    const { id, question, answer, options, type } = body;

    editQuestion(id, question, type, options, answer)
        .then(() => {
            Response.OK(res).send(JSON.stringify("Question edited"));
        });
}