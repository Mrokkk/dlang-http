import std.file;
import std.stdio: writeln;
import std.path: baseName, absolutePath;

import vibe.vibe;
import vibe.appmain;
import vibe.http.router;
import vibe.http.server;
import vibe.http.fileserver;

void handleFile(string filename, HTTPServerResponse res) {
    if (filename.endsWith(".html")) {
        res.writeBody(filename.readText(), "text/html");
    }
    else {
        res.writeBody(filename.readText());
    }
}

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    string title = "Directory listing " ~ req.path;
    auto filename = req.path[1..$];
    writeln(req.path);
    if (filename.length) {
        if (!filename.isDir()) {
            handleFile(filename, res);
            return;
        }
    }
    auto files = dirEntries(filename, "*", SpanMode.shallow, false);
    res.render!("index.dt", title, files, baseName);
}

void configureLogger() {
    auto logger = cast(shared)new HTMLLogger("log.html");
    registerLogger(logger);
}

HTTPServerSettings createHTTPSettings() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];
    return settings;
}

URLRouter createRouter() {
    auto router = new URLRouter;
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = "/static";
    router.get("/static/*", serveStaticFiles("./public/", fsettings));
    router.get("/*", &handleRequest);
    return router;
}

void main() {
    configureLogger();
    listenHTTP(createHTTPSettings(), createRouter());
    runApplication();
}
