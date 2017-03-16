import std.file;
import std.stdio: writeln;
import std.path: baseName;

import vibe.vibe;
import vibe.appmain;
import vibe.http.router;
import vibe.http.server;
import vibe.http.fileserver;

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    string title = "Directory listing " ~ req.path;
    writeln(req.path);
    auto files = dirEntries(req.path[1..$], "*", SpanMode.shallow, false);
    res.render!("index.dt", title, files, baseName);
}

void main() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    auto router = new URLRouter;
    auto fsettings = new HTTPFileServerSettings;
    fsettings.serverPathPrefix = "/static";
    router.get("/static/*", serveStaticFiles("./public/", fsettings));
    router.get("/*", &handleRequest);
    listenHTTP(settings, router);
    runApplication();
}
