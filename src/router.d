module router;

import std.file;
import std.path;
import std.regex;
import std.algorithm;
import std.exception;
import std.stdio: writeln;

import vibe.vibe;
import vibe.http.router;

void handleFile(string filename, HTTPServerRequest req, HTTPServerResponse res) {
    auto query = req.query;
    if (query.length) {
        if (!collectException(query["download"])) {
            res.writeBody(filename.readText());
            return;
        }
    }
    auto title = "File content";
    auto file_content = filename.readText();
    auto dirList = pathSplitter("/" ~ filename);
    res.render!("file.dt", dirList, file_content);
}

void handleDir(string dirName, HTTPServerRequest req, HTTPServerResponse res) {
    auto query = req.query;
    if (query.length) {
        if (!collectException(handleSearch(dirName, query["search"], res))) {
            return;
        }
    }
    auto files = dirEntries(dirName, SpanMode.shallow, false);
    auto baseDir = "/" ~ dirName;
    auto dirList = pathSplitter("/" ~ dirName);
    res.render!("dir_listing.dt", dirList, files, baseDir);
}

void handleSearch(string dirName, string query, HTTPServerResponse res) {
    auto regex = std.regex.regex!string(".*" ~ query ~ ".*", "i");
    auto files = dirEntries(dirName, SpanMode.depth)
        .filter!(a => a.name.match(regex));
    auto baseDir = "/" ~ dirName;
    auto dirList = [""];
    res.render!("dir_listing.dt", dirList, files, baseDir);
}

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto filename = req.path[1..$];
    if (filename.length) {
        if (!filename.isDir()) {
            handleFile(filename, req, res);
            return;
        }
    }
    handleDir(filename, req, res);
}

URLRouter createRouter() {
    auto router = new URLRouter;
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = "/static";
    router.get("/static/*", serveStaticFiles("./public/", fsettings));
    router.get("/*", &handleRequest);
    return router;
}
