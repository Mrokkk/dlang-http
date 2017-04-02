module router;

import std.file;
import std.path;
import std.exception;
import std.datetime;
import std.stdio: writeln;

import vibe.vibe;
import vibe.inet.path;
import vibe.http.router;
import vibe.http.fileserver;

import mime.text;

import api: handleApi;
import logger: Logger;

string html;

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

void add_statics(URLRouter router, string prefix, string path, void delegate(scope HTTPServerRequest req, scope HTTPServerResponse res, ref string path) callback) {
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
    router.get("/*", &handleRequest);
    router.post("/api", &handleApi);
    return router;
}
