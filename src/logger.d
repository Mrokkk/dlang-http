module logger;

import std.conv;
import std.stdio: writeln;
import std.datetime: Clock;

import vibe.http.server;

static class Logger {

    static void log(HTTPServerRequest req, HTTPServerResponse res) {
        auto dateTime = Clock.currTime();
        string color;
        string additional;
        auto reset = "\033[0m";
        switch (req.method) {
            case HTTPMethod.GET:
                color = "\033[1;32m";
                break;
            case HTTPMethod.POST:
                color = "\033[1;35m";
                break;
            case HTTPMethod.HEAD:
                color = "\033[1;36m";
                break;
            default:
                break;
        }
        if (res.statusCode != 200) {
            color = "\033[1;31m";
            additional = " " ~ to!string(res.statusCode);
        }
        writeln(dateTime.toSimpleString(), " ", req.peer, " ", color, req.method, " ", req.requestURL, " ", req.headers["User-Agent"], additional, reset);
    }

};
