import pg from 'pg';
const { Client } = pg;

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME
}

var client = null;

function query(text, params) {
    client = new Client(dbConfig);

    return new Promise((resolve, reject) => {
        client
            .connect()
            .then(() => {
                client
                    .query(text, params, (err, result) => {
                        if (err) {
                            throw err;
                        }
                        client.end();
                        resolve(result);
                    });
            });
    });
}

export function createQuiz(quiz, user_id, code) {
    return new Promise((resolve, reject) => {
        query('INSERT INTO quizzes (name, user_id, code) VALUES ($1, $2, $3) RETURNING code', [quiz, user_id, code])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

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

export function getQuestions(quiz_id) {
    return new Promise((resolve, reject) => {
        query('SELECT * FROM questions WHERE quiz_id = $1', [quiz_id])
            .then(result => {
                resolve(result.rows);
            })
            .catch(err => {
                reject(err);
            });
    });
}

export function createQuestion(quiz_id, question, type, options, answer) {
    return new Promise((resolve, reject) => {
        query('INSERT INTO questions (quiz_id, question, type, options, answer) VALUES ($1, $2, $3, $4, $5)', [quiz_id, question, type, options, answer])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

export function deleteQuestion(id) {
    return new Promise((resolve, reject) => {
        query("DELETE FROM questions WHERE id = $1", [id])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    })
}

export function editQuestion(id, question, type, options, answer) {
    return new Promise((resolve, reject) => {
        query("UPDATE questions SET question = $1, type = $2, options = $3, answer = $4 WHERE id = $5", [question, type, options, answer, id])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}

export function getHashedPassword(username) {
    return new Promise((resolve, reject) => {
        query('SELECT password FROM users WHERE username = $1', [username])
            .then(result => {
                resolve(result.rows[0].password);
            })
            .catch(err => {
                reject(err);
            });
    });
}


export function login(username, password) {

}

export function register(username, hashed_password) {
    return new Promise((resolve, reject) => {
        query('INSERT INTO users (username, password) VALUES ($1, $2)', [username, hashed_password])
            .then(() => {
                resolve();
            })
            .catch(err => {
                reject(err);
            });
    });
}