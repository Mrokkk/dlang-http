module api;

import std.regex;
import std.path;
import std.file;
import std.stdio: writeln;
import std.datetime: Clock;
import std.algorithm: filter;
import std.exception: collectException;

import vibe.vibe;

struct DirListing {

    struct Entry {
        string filename;
        ulong size;
        string mtime;
        bool isDir;
    };

};

void handleSearch(string dirName, string query, HTTPServerResponse res) {
    auto regex = std.regex.regex!string(".*" ~ query ~ ".*", "i");
    auto files = dirEntries(dirName, SpanMode.depth)
        .filter!(a => a.name.baseName.match(regex));
    DirListing.Entry[] entries;
    foreach (file; files) {
        entries ~= DirListing.Entry(file.name, file.size, file.timeLastModified.toISOExtString(), file.isDir);
    }
    res.writeJsonBody = entries.serializeToJson();
}

void handleApi(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto dateTime = Clock.currTime();
    writeln(dateTime, " ", req.peer, " ", req.method, " ", req.requestURL, " ", req.headers["User-Agent"]);
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
