import vibe.appmain;
import vibe.vibe;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
    string title = "Hello World!";
    res.render!("index.dt", title);
}

void main()
{
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    auto router = new URLRouter;
    router.get("/", &handleRequest);
    auto fileServerSettings = new HTTPFileServerSettings;
    router.get("*", serveStaticFiles("./public/"));
    listenHTTP(settings, router);
    runApplication();
}
