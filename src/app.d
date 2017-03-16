import vibe.vibe;
import vibe.appmain;
import vibe.http.server;
import vibe.http.fileserver;
import std.stdio;
import router: createRouter;

void configureLogger() {
    auto consoleLogger = cast(shared) new FileLogger(stdout, stdout);
    registerLogger(consoleLogger);
}

HTTPServerSettings createHTTPSettings() {
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];
    return settings;
}

void main() {
    configureLogger();
    listenHTTP(createHTTPSettings(), createRouter());
    runApplication();
}
