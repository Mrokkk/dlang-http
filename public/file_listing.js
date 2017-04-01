$.when(
    $.getScript("/static/helpers.js"),
    $.Deferred(function(deferred) {
        $(deferred.resolve);
    })
).done(function() {
    $(document).ready(function() {
        createPathButtons();
        $.ajax({
            type: 'HEAD',
            url: '?download',
            complete: function(xhr) {
                var contentType = xhr.getResponseHeader('Content-Type').split("/")[0];
                if (contentType == "text") {
                    var pre = document.createElement("pre");
                    pre.id = "fileContent";
                    pre.className = "prettyprint";
                    pre.style = "border: 0; background-color: transparent;";
                    $("#panel-body").append(pre);
                    $("#fileContent").load("?download", function() {
                        prettyPrint();
                    });
                }
                else if (contentType == "image") {
                    var center = document.createElement("center");
                    var img = document.createElement("img");
                    img.src = "?download";
                    center.appendChild(img);
                    $("#panel-body").append(center);
                }
                else {
                    var p = document.createElement("p");
                    p.align = "center";
                    p.innerHTML = "Binary file";
                    $("#panel-body").append(p);
                }
            }
        });
    });
});
