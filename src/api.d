module api;

import std.uri: decode;
import std.datetime: Clock;
import std.regex: regex, match;
import std.exception: collectException;
import std.algorithm: filter, startsWith;
import std.path: baseName, asRelativePath;
import std.file: isFile, exists, dirEntries, SpanMode, getcwd;

import vibe.http.server: HTTPServerRequest, HTTPServerResponse;
import vibe.data.json: serializeToJson, deserializeJson;

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
    auto reg = regex!string(".*" ~ query ~ ".*", "i");
    auto files = dirEntries(dirName, SpanMode.depth)
        .filter!(a => a.name.baseName.match(reg));
    Response.Entry[] entries;
    foreach (file; files) {
        entries ~= Response.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
    Response resp;
    resp.entries = entries;
    res.writeJsonBody = resp.serializeToJson();
}

void handleApi(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    Request request = deserializeJson!Request(req.queryString.decode);
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
