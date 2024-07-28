import bcrypt from 'bcrypt';
import { ADMIN_USER } from './utils.js';

import { createClient } from '@supabase/supabase-js'

const supabase = createClient('https://shdjeiwicumactjbalkv.supabase.co', process.env.ANON, { schema: 'public' });


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

    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('quizzes')
            .select('user_id')
            .eq('id', quiz_id)

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            return false;
        }

        resolve(data[0].user_id === user_id);
    });
}

/**
 * 
 * @param {string} quiz 
 * @param {string} user_id 
 * @param {string} code 
 * @returns {Promise<void>}
 */
export function createQuiz(quiz, description, user_id, code, color) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from("quizzes")
            .insert({ name: quiz, description: description, user_id: user_id, code: code, color: color, })
            .select('id');

        if (error) {
            reject(error);
            return;
        }

        resolve(data[0].id);
    });
}

export function getQuizzes(user_id) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from("quizzes")
            .select('*')
            .eq('user_id', user_id);

        if (error) {
            reject(error);
            return;
        }

        resolve(data);
    });

}

export async function getQuizById(id, user_id) {
    if (!await checkAuthorization(user_id, id)) {
        reject("Unauthorized");
        return;
    }

    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('quizzes')
            .select('*')
            .eq('id', id);

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            reject("Quiz not found");
            return;
        }

        resolve(data[0]);
    })
}

/**
 * 
 * @param {string} code 
 * @returns {Promise<Object>}
 */
export function getQuizByCode(code) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('quizzes')
            .select('*')
            .eq('code', code)

        if (error) {
            reject(error);
            return;
        }

        resolve(data[0]);
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

    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('questions')
            .select('*')
            .eq('quiz_id', quiz_id);

        if (error) {
            reject(error);
            return;
        }

        const rows = data.map(row => {
            return {
                id: row.id,
                quiz_id: row.quiz_id,
                question: row.question,
                type: row.type,
                options: row.options,
                index: row.index,
                answer: return_answer ? row.answer : null,
            }
        });
        resolve(rows);
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

        const { data, error } = await supabase
            .from('questions')
            .insert({
                quiz_id: quiz_id,
                question: question,
                type: type,
                options: options,
                answer: answer,
                index: index
            })
            .select('id');

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            reject("Failed to create question");
            return;
        }

        resolve(data[0].id);
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

        const { error } = await supabase
            .from('questions')
            .delete()
            .eq('id', id);

        if (error) {
            reject(error);
            return;
        }

        resolve();
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

        const { error } = await supabase
            .from('questions')
            .update({
                question: question,
                type: type,
                options: options,
                answer: answer
            })
            .eq('id', id);

        if (error) {
            reject(error);
            return;
        }

        resolve();
    });
}

/**
 * 
 * @param {string} username 
 * @returns {Promise<{hash: string, id: string}>}
 */
export function getHashedPassword(username) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('accounts')
            .select('password, id')
            .eq('username', username);

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            reject("User not found");
            return;
        }

        resolve({ hash: data[0].password, id: data[0].id });
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
                    return;
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
    return new Promise(async (resolve, reject) => {
        const { error } = await supabase
            .from('accounts')
            .insert({
                username: username,
                password: hashed_password
            });

        if (error) {
            reject(error);
            return;
        }

        resolve();
    });
}

/**
 * 
 * @param {string} token 
 * @returns {Promise<string>}
 */
export function authenticate(token) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from("tokens")
            .select("account_id")
            .eq("token", token);

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            ű
            reject("Unauthorized");
        }

        resolve(data[0].account_id);
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

    await supabase
        .from('tokens')
        .insert({
            account_id: id,
            token: result
        });

    return result;
}


/**
 * 
 * @param {number} question_id 
 * @returns {Promise<number>}
 */
function getQuizOfQuestion(question_id) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('questions')
            .select('quiz_id')
            .eq('id', question_id);

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            reject("Question not found");
            return
        }

        resolve(data[0].quiz_id);
    });
}


/**
 * 
 * @param {number} answer_id 
 * @param {string} user_id 
 * @returns {Promise<Object>}
 */
export function getAnswerById(answer_id, user_id) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('answers')
            .select('*')
            .eq('id', answer_id);

        if (error) {
            reject(error);
            return;
        }

        if (data[0].account_id !== user_id) {
            reject("Unauthorized");
            return;
        }

        resolve(data[0]);
    });
}

/**
 * 
 * @param {number} quiz_id 
 * @param {string} user_id 
 * @returns {Promise<Object[]>}
 */
export function getAnswersByQuizId(quiz_id, user_id) {
    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        const { data, error } = await supabase
            .from('answers')
            .select('*')
            .eq('quiz_id', quiz_id);

        if (error) {
            reject(error);
            return;
        }

        resolve(data);
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
        const { error } = await supabase
            .from('answers')
            .insert({
                account_id: user_id,
                quiz_id: quiz_id,
                answers: answers,
                scores_earned: score_earned
            });

        if (error) {
            console.log(error.message);
            reject(error);
            return;
        }

        resolve();
    });
}

/**
 * 
 * @param {string} user_id 
 * @param {number} quiz_id 
 * @param {string} name 
 * @returns 
 */
export function editQuiz(user_id, quiz_id, name, description) {
    return new Promise(async (resolve, reject) => {
        if (!await checkAuthorization(user_id, quiz_id)) {
            reject("Unauthorized");
            return;
        }

        const { error } = await supabase
            .from('quizzes')
            .update({
                name: name,
                description: description,
            })
            .eq('id', quiz_id);

        if (error) {
            reject(error);
            return;
        }

        resolve();
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

        const { error } = await supabase
            .from('quizzes')
            .delete()
            .eq('id', quiz_id);

        if (error) {
            reject(error);
            return;
        }

        resolve();
    });
}

export function logOut(token) {
    return new Promise(async (resolve, reject) => {
        const { error } = await supabase
            .from('tokens')
            .delete()
            .eq('token', token);

        if (error) {
            reject(error);
            return;
        }

        resolve();
    });
}

export function getUsername(user_id) {
    return new Promise(async (resolve, reject) => {
        const { data, error } = await supabase
            .from('accounts')
            .select('username')
            .eq('id', user_id);

        if (error) {
            reject(error);
            return;
        }

        if (data.length === 0) {
            reject("User not found");
            return;
        }

        resolve(data[0].username);
    });
}