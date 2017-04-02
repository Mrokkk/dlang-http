module logger;

import std.stdio: writeln;
import std.datetime: Clock;

import vibe.http.server;

static class Logger {

    static void log(HTTPServerRequest req, HTTPServerResponse res) {
        auto dateTime = Clock.currTime();
        writeln(dateTime, " ", req.peer, " ", req.method, " ", req.requestURL, " ", req.headers["User-Agent"]);
    }

};
