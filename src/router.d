module router;

import std.file;
import std.path;
import std.regex;
import std.algorithm;
import std.exception;
import std.stdio: writeln;

import vibe.vibe;
import vibe.http.router;

void handleFile(string filename, HTTPServerResponse res) {
    if (filename.endsWith(".html")) {
        res.writeBody(filename.readText(), "text/html");
    }
    else {
        res.writeBody(filename.readText());
    }
}

void handleDir(string dirName, HTTPServerResponse res) {
    auto files = dirEntries(dirName, SpanMode.shallow, false);
    auto baseDir = "/" ~ dirName;
    auto title = "Directory listing" ~ baseDir;
    res.render!("dir_listing.dt", title, files, baseDir);
}

void handleSearch(string dirName, string query, HTTPServerResponse res) {
    auto regex = std.regex.regex!string(".*" ~ query ~ ".*", "i");
    auto files = dirEntries(dirName, SpanMode.depth)
        .filter!(a => a.name.match(regex));
    auto baseDir = "/" ~ dirName;
    auto title = "Search result for " ~ query ~ " in " ~ baseDir;
    res.render!("dir_listing.dt", title, files, baseDir);
}

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto filename = req.path[1..$];
    auto query = req.query;
    if (query.length) {
        Exception e = collectException(handleSearch(filename, query["search"], res));
        if (e) {
            handleDir(filename, res);
            return;
        }
        return;
    }
    if (filename.length) {
        if (!filename.isDir()) {
            handleFile(filename, res);
            return;
        }
    }
    handleDir(filename, res);
}

URLRouter createRouter() {
    auto router = new URLRouter;
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = "/static";
    router.get("/static/*", serveStaticFiles("./public/", fsettings));
    router.get("/*", &handleRequest);
    return router;
}
