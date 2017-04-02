module api;

import std.regex;
import std.path;
import std.file;
import std.datetime: Clock;
import std.algorithm: filter;
import std.exception: collectException;

import vibe.vibe;
import logger: Logger;

struct Response {

    struct Entry {
        string filename;
        ulong size;
        string mtime;
        bool isDir;
    };

    Entry[] entries;
    bool file;

};

struct Request {

    string path;
    string search;

};

void handleSearch(string dirName, string query, HTTPServerResponse res) {
    auto regex = std.regex.regex!string(".*" ~ query ~ ".*", "i");
    auto files = dirEntries(dirName, SpanMode.depth)
        .filter!(a => a.name.baseName.match(regex));
    Response.Entry[] entries;
    foreach (file; files) {
        entries ~= Response.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
    Response resp;
    resp.entries = entries;
    res.writeJsonBody = resp.serializeToJson();
}

void handleApi(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    Logger.log(req, res);
    Request request = deserializeJson!Request(req.json);
    Response response;
    if (request.path == "") {
        res.statusCode = 404;
        return;
    }
    auto path = request.path[1..$];
    if (path != "") {
        if (asRelativePath(path, getcwd()).startsWith("..")) {
            res.statusCode = 404;
            return;
        }
        if (!path.exists()) {
            res.statusCode = 404;
            return;
        }
        if (path.isFile()) {
            response.file = true;
            res.writeJsonBody = response.serializeToJson();
            return;
        }
        else {
            response.entries ~= Response.Entry("..", 0, "", true);
        }
    }
    if (request.search != "") {
        handleSearch(path, request.search, res);
        return;
    }
    auto files = dirEntries(path, SpanMode.shallow, false);
    foreach (file; files) {
        response.entries ~= Response.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
    response.file = false;
    res.writeJsonBody = response.serializeToJson();
    return;
}
