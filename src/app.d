import std.path: dirName;

import vibe.http.server;
import vibe.core.core: runApplication;

import router: createRouter;
import logger: Logger;

HTTPServerSettings createHTTPSettings() {
    auto settings = new HTTPServerSettings;
    with (settings) {
        port = 8080;
        bindAddresses = ["0.0.0.0"];
        errorPageHandler = (req, res, err) {
            Logger.log(req, res);
            auto error = res.statusCode;
            if (error != 401 && error != 404) {
                res.statusCode = 500;
            }
        };
    }
    return settings;
}

void main(string[] argv) {
    listenHTTP(createHTTPSettings(), createRouter(dirName(argv[0])));
    runApplication();
}
