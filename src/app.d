import vibe.vibe;
import vibe.appmain;
import vibe.http.server;
import vibe.http.fileserver;
import std.stdio;
import std.path: dirName;
import router: createRouter;

HTTPServerSettings createHTTPSettings() {
    auto settings = new HTTPServerSettings;
    with (settings) {
        port = 8080;
        bindAddresses = ["0.0.0.0"];
        errorPageHandler = (req, res, err) {
            auto error = res.statusCode;
            res.render!("error.dt", error);
        };
    }
    return settings;
}

void main(string[] argv) {
    listenHTTP(createHTTPSettings(), createRouter(dirName(argv[0])));
    runApplication();
}
