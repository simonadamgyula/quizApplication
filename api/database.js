import bcrypt from 'bcrypt';
import pg from 'pg';
const { Client } = pg;
import { ADMIN_USER } from './utils.js';

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    idleTimeoutMillis: 0,
    connectionTimeoutMillis: 0,
}

var client = null;


/**
 * 
 * @param {string} text 
 * @param {Array} params 
 * @returns {*}
 */
function query(text, params) {
    client = new Client(dbConfig);
    console.log(text);
    console.log(params);

    return new Promise((resolve, reject) => {
        client
            .connect()
            .then(() => {
                client
                    .query(text, params, (err, result) => {
                        if (err) {
                            client.end()
                            console.log(err);
                            reject(err);
                        }
                        client.end();
                        resolve(result);
                    });
            });
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} quiz_id 
 * @returns {Promise<boolean>}
 */
function checkAuthorization(user_id, quiz_id) {
    if (user_id === ADMIN_USER) {
        return true;
    }

    return new Promise((resolve, reject) => {
        query('SELECT user_id FROM quizzes WHERE id = $1', [quiz_id])
            .then(result => {
                console.log(result.rows[0]);
                resolve(result.rows[0].user_id === user_id);
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} quiz 
 * @param {string} user_id 
 * @param {string} code 
 * @returns {Promise<void>}
 */
export function createQuiz(quiz, user_id, code, color) {
    return new Promise((resolve, reject) => {
        query('INSERT INTO quizzes (name, user_id, code, color) VALUES ($1, $2, $3, $4) RETURNING id', [quiz, user_id, code, color])
            .then(result => {
                resolve(result.rows[0].id);
            })
            .catch(err => {
                reject(err);
            });
    });
}

export function getQuizzes(user_id) {
    return new Promise((resolve, reject) => {
        query('SELECT * FROM quizzes WHERE user_id = $1', [user_id])
            .then(result => {
                resolve(result.rows);
            })
            .catch(err => {
                reject(err);
            });
    });

}

export async function getQuizById(id, user_id) {
    if (!await checkAuthorization(user_id, id)) {
        reject("Unauthorized");
        return;
    }

    return new Promise((resolve, reject) => {
        query('SELECT * FROM quizzes WHERE id = $1', [id])
            .then(result => {
                resolve(result.rows[0]);
            })
            .catch(err => {
                reject(err);
            });
    })
}

/**
 * 
 * @param {string} code 
 * @returns {Promise<Object>}
 */
export function getQuizByCode(code) {
    return new Promise((resolve, reject) => {
        query('SELECT * FROM quizzes WHERE code = $1', [code])
            .then(result => {
                resolve(result.rows[0]);
            })
            .catch(err => {
                reject(err);
            });
    });
}


/**
 * 
 * @param {number} quiz_id 
 * @returns {Promise<Object[]>}
 */
export async function getQuestions(quiz_id, user_id) {
    var return_answer = false;
    if (await checkAuthorization(user_id, quiz_id)) {
        return_answer = true;
    }

    return new Promise((resolve, reject) => {
        query('SELECT * FROM questions WHERE quiz_id = $1', [quiz_id])
            .then(result => {
                const rows = result.rows.map(row => {
                    return {
                        id: row.id,
                        quiz_id: row.quiz_id,
                        question: row.question,
                        type: row.type,
                        options: row.options,
                        index: row.index,
                        answer: return_answer ? row.answer : null,
                    }
                }
                )
                resolve(rows);
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} quiz_id 
 * @param {string} question 
 * @param {number} type 
 * @param {string[] | any} options 
 * @param {string | any} answer 
 * @returns {Promise<void>}
 */
export function createQuestion(user_id, quiz_id, question, type, options, answer, index) {
    console.log(options);

    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        query('INSERT INTO questions (quiz_id, question, type, options, answer, index) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id', [quiz_id, question, type, options, answer, index])
            .then(result => {
                resolve(result.rows[0].id);
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} id 
 * @returns {Promise<void>}
 */
export function deleteQuestion(user_id, id) {
    return new Promise(async (resolve, reject) => {
        const quiz_id = await getQuizOfQuestion(id);

        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        query("DELETE FROM questions WHERE id = $1", [id])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    })
}

/**
 * 
 * @param {string} user_id 
 * @param {number} id 
 * @param {string} question 
 * @param {number} type 
 * @param {string[] | any} options 
 * @param {string | any} answer 
 * @returns {Promise<void>}
 */
export function editQuestion(user_id, id, question, type, options, answer) {
    return new Promise(async (resolve, reject) => {
        const quiz_id = await getQuizOfQuestion(id);

        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        query("UPDATE questions SET question = $1, type = $2, options = $3, answer = $4 WHERE id = $5", [question, type, options, answer, id])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} username 
 * @returns {Promise<{hash: string, id: string}>
 */
export function getHashedPassword(username) {
    return new Promise((resolve, reject) => {
        query('SELECT password, id FROM accounts WHERE username = $1', [username])
            .then(result => {
                resolve({ hash: result.rows[0].password, id: result.rows[0].id });
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} username 
 * @param {strign} password 
 * @returns {Promise<string>}
 */
export async function login(username, password) {
    const { hash, id } = await getHashedPassword(username);

    return new Promise((resolve, reject) => {
        bcrypt.compare(password, hash, async (err, result) => {
            if (err) {
                reject(err);
            }

            if (result) {
                const token = await newToken(id);

                if (token) {
                    resolve(token);
                }
            }

            reject("Invalid password");
        });
    });
}


/**
 * 
 * @param {string} username 
 * @param {string} hashed_password 
 * @returns {Promise<void>}
 */
export function register(username, hashed_password) {
    return new Promise((resolve, reject) => {
        query('INSERT INTO accounts (username, password) VALUES ($1, $2)', [username, hashed_password])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} token 
 * @returns {Promise<string>}
 */
export function authenticate(token) {
    return new Promise((resolve, reject) => {
        query('SELECT account_id FROM tokens WHERE token = $1', [token])
            .then(result => {
                resolve(result.rows[0].account_id);
            })
            .catch(err => {
                reject(err);
            });
    });
}


/**
 * 
 * @param {string} id 
 * @returns {Promise<string>}
 */
async function newToken(id) {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < 78) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
        counter += 1;
    }

    await query('INSERT INTO tokens (token, account_id) VALUES ($1, $2)', [result, id])
        .catch(err => {
            return null;
        });

    return result;
}


/**
 * 
 * @param {number} question_id 
 * @returns {Promise<number>}
 */
function getQuizOfQuestion(question_id) {
    return new Promise((resolve, reject) => {
        query('SELECT quiz_id FROM questions WHERE id = $1', [question_id])
            .then(result => {
                console.log(result.rows[0])
                resolve(result.rows[0].quiz_id);
            })
            .catch(err => {
                reject(err);
            });
    });
}


/**
 * 
 * @param {number} answer_id 
 * @param {string} user_id 
 * @returns {Promise<Object>}
 */
export function getAnswerById(answer_id, user_id) {
    return new Promise((resolve, reject) => {
        query('SELECT * FROM answers WHERE id = $1', [answer_id])
            .then(async result => {
                const row = result.rows[0];
                if (!await checkAuthorization(user_id, question_id) && row.user_id !== user_id) {
                    reject("Unauthorized");
                    return;
                }

                resolve(row);
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {number} question_id 
 * @param {string} user_id 
 * @returns {Promise<Object[]>}
 */
export function getAnswersByQuestionId(question_id, user_id) {
    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, question_id)) {
            reject("Unauthorized");
            return;
        }

        query('SELECT * FROM answers WHERE question_id = $1', [question_id])
            .then(result => {
                resolve(result.rows);
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} quiz_id
 * @param {*} answers 
 * @param {number} score_earned 
 * @returns {Promise<void>}
 */
export function submitAnswer(user_id, quiz_id, answers, score_earned) {
    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        query('INSERT INTO answers (account_id, quiz_id, answers, scores_earned) VALUES ($1, $2, $3, $4)', [user_id, quiz_id, answers, score_earned])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} quiz_id 
 * @param {string} name 
 * @returns 
 */
export function editQuiz(user_id, quiz_id, name) {
    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        query('UPDATE quizzes SET name = $1 WHERE id = $2', [name, quiz_id])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} quiz_id 
 * @returns 
 */
export function deleteQuiz(user_id, quiz_id) {
    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        query('DELETE FROM quizzes WHERE id = $1', [quiz_id])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

export function logOut(token) {
    return new Promise((resolve, reject) => {
        query('DELETE FROM tokens WHERE token = $1', [token])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            })
    });
}