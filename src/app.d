import vibe.vibe;
import vibe.appmain;
import vibe.http.server;
import vibe.http.fileserver;
import router: createRouter;

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

void main() {
    configureLogger();
    listenHTTP(createHTTPSettings(), createRouter());
    runApplication();
}
