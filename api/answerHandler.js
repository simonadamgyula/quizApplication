import { Response } from "./response.js";
import { authenticateUser } from "./authentication.js";
import { getAnswerById, getAnswersByQuestionId, submitAnswer, getQuestions } from "./database.js";

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

    const { quiz_id, answers } = body;

    var score_earned = 0;
    try {
        score_earned = await validateAnswers(quiz_id, answers);
    } catch (e) {
        Response.BadRequest(res).send(e.message);
        return;
    }

    submitAnswer(user_id, quiz_id, answers, score_earned)
        .then(() => {
            Response.OK(res).send({ score: score_earned });
        });
}

async function validateAnswers(quiz_id, answers) {
    const questions = await getQuestions(quiz_id, true);
    var scores = [];

    if (questions.length !== Object.keys(answers).length) {
        throw Error("Invalid number of answers");
    }

    for (let i = 0; i < questions.length; i++) {
        const question = questions[i];
        switch (parseInt(question.type)) {
            case 0:
            case 1:
            case 3:
            case 4:
            case 6:
                if (answers[question.id.toString()] !== question.answer) {
                    scores.push(0);
                } else {
                    scores.push(1);
                }
                break;
            case 2:
            case 5:
                const selected = answers[question.id.toString()].split(",");
                const correct = question.answer.split(",");

                var score = 0;

                for (let single_selected in selected) {
                    if (!correct.includes(single_selected)) {
                        score--;
                        continue;
                    }
                    score++;
                }

                scores.push(Math.max(0, score));
                break;
        }
    }

    return scores.reduce((a, b) => a + b, 0);
}