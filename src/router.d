module router;

import std.file;
import std.path;
import std.regex;
import std.algorithm;
import std.exception;
import std.stdio: writeln;

import vibe.vibe;
import vibe.inet.path;
import vibe.http.router;
import vibe.http.fileserver;

void handleFile(string filename, HTTPServerRequest req, HTTPServerResponse res) {
    auto query = req.query;
    if (query.length) {
        if (!collectException(query["download"])) {
            sendFile(req, res, Path(filename));
            return;
        }
    }
    auto title = "File content";
    auto dirList = pathSplitter("/" ~ filename);
    res.render!("file_listing.dt", dirList, filename);
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
    string[] dirList;
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
