module router;

import std.file;
import std.path;
import std.regex;
import std.algorithm;
import std.exception;
import std.datetime;
import std.stdio: writeln;

import vibe.vibe;
import vibe.inet.path;
import vibe.http.router;
import vibe.http.fileserver;

struct DirListing {

    struct Entry {
        string filename;
        ulong size;
        string mtime;
        bool isDir;
    };

};

void handleFile(string filename, HTTPServerRequest req, HTTPServerResponse res) {
    auto query = req.query;
    if (query.length) {
        if (!collectException(query["download"])) {
            sendFile(req, res, Path(filename));
            return;
        }
    }
    res.render!("file_listing.dt");
}

void handleDir(string dirName, HTTPServerRequest req, HTTPServerResponse res) {
    res.render!("dir_listing.dt");
}

void handleSearch(string dirName, string query, HTTPServerResponse res) {
    auto regex = std.regex.regex!string(".*" ~ query ~ ".*", "i");
    auto files = dirEntries(dirName, SpanMode.depth)
        .filter!(a => a.name.match(regex));
    DirListing.Entry[] entries;
    foreach (file; files) {
        entries ~= DirListing.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
    res.writeJsonBody = entries.serializeToJson();
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

void handleApi(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto dateTime = Clock.currTime();
    writeln(dateTime, " API ", req.peer, " ", req.method, " ", req.requestURL, " ", req.headers["User-Agent"]);
    auto path = req.json["path"].get!string;
    if (path == "") {
        res.statusCode = 404;
        return;
    }
    path = path[1..$];
    if (!collectException(req.json["search"].get!string)) {
        auto search = req.json["search"].get!string;
        writeln("search: ", search);
        handleSearch(path, search, res);
        return;
    }
    DirListing.Entry[] entries;
    auto files = dirEntries(path, SpanMode.shallow, false);
    foreach (file; files) {
        entries ~= DirListing.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
    res.writeJsonBody = entries.serializeToJson();
    return;
}

URLRouter createRouter(string dir) {
    auto router = new URLRouter;
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = "/static";
    router.get("/static/*", serveStaticFiles(dir ~ "/public/", fsettings));
    router.get("/*", &handleRequest);
    router.post("/api", &handleApi);
    return router;
}
