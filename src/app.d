import std.path: dirName;

import vibe.core.core: runApplication;
import vibe.http.server: listenHTTP, HTTPServerSettings;

import router: createRouter;

HTTPServerSettings createHTTPSettings() {
    auto settings = new HTTPServerSettings;
    with (settings) {
        port = 8080;
        bindAddresses = ["0.0.0.0"];
        accessLogToConsole = true;
        accessLogFormat = "%h - %u %t \"%r\" %s %b \"%{User-Agent}i\"";
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
