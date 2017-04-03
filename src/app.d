import std.path: dirName;

import vibe.core.core: runApplication;
import vibe.http.server: listenHTTP, HTTPServerSettings;

import router: createRouter;

HTTPServerSettings createHTTPSettings() {
    auto settings = new HTTPServerSettings;
    auto resetColor = "\033[0m";
    auto userAgentColor = "\033[0;35m";
    auto methodColor = "\033[32m";
    auto responseColor = "\033[1;34m";
    with (settings) {
        port = 8080;
        bindAddresses = ["0.0.0.0"];
        accessLogToConsole = true;
        accessLogFormat = "%h - %u %t " ~ methodColor ~ "\"%r\"" ~ responseColor ~ " %s %b " ~ userAgentColor ~ "\"%{User-Agent}i\"" ~ resetColor;
        errorPageHandler = (req, res, err) {
            auto error = res.statusCode;
            if (error != 401 && error != 404) {
                res.statusCode = 500;
            }
            res.writeBody("Error processing request");
        };
    }
    return settings;
}

void main(string[] argv) {
    listenHTTP(createHTTPSettings(), createRouter(dirName(argv[0])));
    runApplication();
}
