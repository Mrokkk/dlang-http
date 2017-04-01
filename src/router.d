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
import api: handleApi;

void handleFile(string filename, HTTPServerRequest req, HTTPServerResponse res) {
    res.render!("file_listing.dt");
}

void handleDir(string dirName, HTTPServerRequest req, HTTPServerResponse res) {
    res.render!("dir_listing.dt");
}

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto dateTime = Clock.currTime();
    writeln(dateTime, " ", req.peer, " ", req.method, " ", req.requestURL, " ", req.headers["User-Agent"]);
    auto filename = req.path[1..$];
    if (filename.length) {
        if (req.path == "/favicon.ico") {
            res.redirect("/static/favicon.ico");
            return;
        }
        if (!filename.exists()) {
            res.statusCode = 404;
            return;
        }
        if (asRelativePath(filename, getcwd()).startsWith("..")) {
            res.statusCode = 404;
            return;
        }
        if (!filename.isDir()) {
            handleFile(filename, req, res);
            return;
        }
    }
    handleDir(filename, req, res);
}

void add_statics(URLRouter router, string prefix, string path) {
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = prefix;
    router.get(prefix ~ "/*", serveStaticFiles(path, fsettings));
}

URLRouter createRouter(string dir) {
    auto router = new URLRouter;
    add_statics(router, "/static", dir ~ "/public/");
    add_statics(router, "/files", "./");
    router.get("/*", &handleRequest);
    router.post("/api", &handleApi);
    return router;
}
