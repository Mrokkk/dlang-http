module router;

import std.file: read, readText;
import std.exception: collectException;

import vibe.http.router: URLRouter;
import vibe.http.server: HTTPServerRequest, HTTPServerResponse;
import vibe.http.fileserver: HTTPFileServerSettings, serveStaticFiles;

import mime.text: isTextualData;

import api: handleApi;
import logger: Logger;

private {
string html;
}

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    Logger.log(req, res);
    if (req.path == "/favicon.ico") {
        res.redirect("/static/favicon.ico");
        return;
    }
    res.writeBody(html, "text/html; charset-UTF-8");
}

void callback(scope HTTPServerRequest req, scope HTTPServerResponse res, ref string path) {
    Logger.log(req, res);
    if (isTextualData(path.read(16))) {
        res.contentType = "text/plain; charset-UTF-8";
    }
}

void add_statics(URLRouter router, string prefix, string path,
        void delegate(scope HTTPServerRequest, scope HTTPServerResponse, ref string) callback) {
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = prefix;
    fsettings.preWriteCallback = callback;
    router.get(prefix ~ "/*", serveStaticFiles(path, fsettings));
}

URLRouter createRouter(string dir) {
    html = (dir ~ "/public/index.html").readText();
    auto router = new URLRouter;
    add_statics(router, "/static", dir ~ "/public/", null);
    add_statics(router, "/files", "./", (req, res, ref path) {
        callback(req, res, path);
    });
    router.get("/api", &handleApi);
    router.get("/*", &handleRequest);
    return router;
}
