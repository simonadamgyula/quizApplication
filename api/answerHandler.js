import { Response } from "./response.js";
import { authenticateUser } from "./authentication.js";
import { ADMIN_USER } from "./utils.js";
import { getAnswerById, getAnswersByQuizId, submitAnswer, getQuestions } from "./database.js";

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

    const { quiz_id } = body;

    var answers = [];
    var details = {};

    try {
        answers = await getAnswersByQuizId(quiz_id, user_id);
    } catch (e) {
        Response.BadRequest(res).send(`Failed to get answers: ${e.message}`);
        return;
    }

    await Promise.all(answers.map(async (answer) => {
        return new Promise(async (resolve, reject) => {
            const [_, detail] = await validateAnswers(quiz_id, answer.answers);
            details[answer.id] = detail;

            resolve();
        });
    }));

    Response.OK(res).send({ answers: answers, details: details });
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

    const [score_earned, details] = await validateAnswers(quiz_id, answers);

    submitAnswer(user_id, quiz_id, answers, score_earned)
        .then(() => {
            Response.OK(res).send({ score: score_earned, details: details });
        })
        .catch(() => {
            Response.BadRequest(res).send("Failed to submit answer");
        });
}

async function validateAnswers(quiz_id, answers) {
    const questions = await getQuestions(quiz_id, ADMIN_USER);
    var scores = [];
    var details = {};

    function multiAnswerValidate(answer, question) {
        const selected = answer.split(",");
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
    }

    for (let i = 0; i < questions.length; i++) {
        const question = questions[i];
        const options = JSON.parse(question.options);
        const answer = answers[question.id.toString()];

        if (!answer) {
            scores.push(0);

            details[question.id] = null;

            continue;
        }

        switch (parseInt(question.type)) {
            case 0:
                scores.push(answer === question.answer ? 1 : 0);
                details[question.id] = [
                    ["True", "False"],
                    [[question.answer === "true", answer === "true"], [question.answer === "false", answer === "false"]],
                ]
                break;
            case 1:
                scores.push(answer === question.answer ? 1 : 0);
                details[question.id] = [
                    options,
                    options.map(option => [option === question.answer, option === answer]),
                ]
                break;
            case 2:
                multiAnswerValidate(answer, question);
                details[question.id] = [
                    options,
                    options.map(option => [question.answer.split(",").includes(option), answer.split(",").includes(option)]),
                ]
                break;
            case 3:
                var score = 0;
                for (let j = 0; j < options.length; j++) {
                    if (options[j] === question.answer.split(",")[j]) {
                        score++;
                    }
                }
                scores.push(score);
                details[question.id] = [
                    options,
                    options.map((option, index) => [index === question.answer.split(",").indexOf(option), index === answer.split(",").indexOf(option)]),
                ]
                break;
            case 4:
                scores.push(answer === question.answer ? 1 : 0);
                break;
            case 5:
                multiAnswerValidate(answer, question);
                break;
            case 6:
                scores.push(answer === question.answer ? 1 : 0);
                break;
        }
    }

    return [scores.reduce((a, b) => a + b, 0), details];
}