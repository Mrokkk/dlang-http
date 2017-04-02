module logger;

import std.stdio: writeln;
import std.datetime: Clock;

import vibe.http.server;

static class Logger {

    static void log(HTTPServerRequest req, HTTPServerResponse res) {
        auto dateTime = Clock.currTime();
        string color;
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
        writeln(dateTime.toSimpleString(), " ", req.peer, " ", color, req.method, " ", req.requestURL, " ", req.headers["User-Agent"], reset);
    }

};
