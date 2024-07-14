import pg from 'pg';
const { Client } = pg;

const client = new Client({
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME
});

function query(text, params) {
    return new Promise((resolve, reject) => {
        client.
            connect().
            then(() => {
                client
                    .query(text, params, (err, result) => {
                        console.log("here");
                        if (err) {
                            throw err;
                        }
                        client.end();
                        resolve(result);
                    })
            });
    });
}

export function createQuiz(quiz, user_id, code) {
    console.log("here");
    return new Promise((resolve, reject) => {
        query('INSERT INTO quizzes (name, user_id, code) VALUES ($1, $2, $3) RETURNING id', [quiz, user_id, code])
            .then(result => {
                const quizId = result.rows[0].id;
                resolve(quizId);
            })
            .catch(err => {
                console.log(err);
                reject(err);
            });
    });
}