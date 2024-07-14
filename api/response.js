export class Response {
    constructor(res, status) {
        this.res = res;
        this.status = status;

        this.headers = {};
    }

    setHeaders(headers) {
        this.headers = headers;
    }

    setHeader(key, value) {
        this.headers[key] = value;
    }

    send(body) {
        this.res.writeHead(this.status, this.headers);
        this.res.write(JSON.stringify(body));
        this.res.end();
    }

    static BadRequest(res) {
        return new Response(res, 400);
    }

    static NotFound(res) {
        return new Response(res, 404);
    }

    static OK(res) {
        return new Response(res, 200);
    }

    static Unauthorized(res) {
        return new Response(res, 401);
    }
}