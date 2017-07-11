module api;

import std.uri: decode;
import std.path: baseName;
import std.datetime: Clock;
import std.regex: regex, match;
import std.algorithm: filter, startsWith, canFind;
import std.file: isFile, exists, dirEntries, SpanMode, getcwd;

import vibe.data.json: serializeToJson, deserializeJson;
import vibe.http.server: HTTPServerRequest, HTTPServerResponse;

private struct Response {

    struct Entry {
        string filename;
        ulong size;
        string mtime;
        bool isDir;
    };

    Entry[] entries;
    bool file;

};

private struct Request {

    string path;

};

private void fillResponse(F)(ref Response response, ref F files) {
    foreach (file; files) {
        response.entries ~= Response.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
}

private void handleDir(const ref string path, ref Response response) {
    response.entries ~= Response.Entry("..", 0, "", true);
    auto files = dirEntries(path, SpanMode.shallow, false);
    fillResponse(response, files);
    response.file = false;
}

private Request readRequest(HTTPServerRequest req) {
    auto request = deserializeJson!Request(req.queryString.decode);
    request.path = "." ~ request.path;
    if (request.path == "" || request.path.canFind("//") || !request.path.exists()) {
        throw new Exception("");
    }
    return request;
}

void handleApi(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    Request request;
    try {
        request = readRequest(req);
    }
    catch(Exception e)
    {
        res.statusCode = 404;
        return;
    }
    auto path = request.path;
    Response response;
    if (path.isFile()) {
        response.file = true;
    }
    else {
        handleDir(path, response);
    }
    res.writeJsonBody = response.serializeToJson();
    return;
}
