function bytesToSize(bytes) {
   var sizes = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
   if (bytes == 0) return '0B';
   var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
   return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
}

function format_cell(cell, proc) {
    cell.style = "vertical-align: middle;";
    cell.width = proc.toString() + "%"
}

function basename(path) {
    return path.split('/').reverse()[0];
}

function stripTrailingSlash(str) {
    if(str.substr(-1) === '/') {
        return str.substr(0, str.length - 1);
    }
    return str;
}

function createPathButtons() {
    var pathname = stripTrailingSlash(window.location.pathname);
    var dirList = [];
    if (pathname == "" || pathname == "/")
        dirList = [""];
    else
        dirList = pathname.split("/");
    var link = "/";
    dirList.forEach(function (entry) {
        if (entry == "") {
            entry = "/";
        }
        else {
            link += entry + "/";
        }
        var button = document.createElement("a");
        if (link != "/")
            button.href = stripTrailingSlash(link);
        else
            button.href = link;
        button.role = "button";
        button.className = "btn btn-primary";
        button.text = entry;
        $("#path-buttons").append(button);
    });
}

function createDownloadBtn(href) {
    var btn = document.createElement("a");
    btn.id = "download-btn";
    btn.className = "btn btn-default pull-right";
    btn.role = "button";
    btn.innerHTML = "<span class='glyphicon glyphicon-download-alt'></span> Download";
    btn.href = href;
    $("#panel-head").append(btn);
}

function dir(data) {
    var table = document.createElement("table");
    table.setAttribute("data-link", "row");
    table.className = "table table-hover table-condensed";
    table.style = "margin-bottom: 0;";
    var tbl_body = document.createElement("tbody");
    $.each(data.entries, function() {
        var tbl_row = tbl_body.insertRow();
        var icon_cell = tbl_row.insertCell();
        var name_cell = tbl_row.insertCell();
        var size_cell = tbl_row.insertCell();
        var mtime_cell = tbl_row.insertCell();
        format_cell(icon_cell, 2);
        format_cell(name_cell, 38);
        format_cell(size_cell, 30);
        format_cell(mtime_cell, 30);
        var a = document.createElement("a");
        a.href = "/" + this.filename;
        a.innerHTML = basename(this.filename);
        name_cell.appendChild(a);
        if (this.isDir) {
            var i = document.createElement("i");
            i.className = "glyphicon glyphicon-folder-open";
            icon_cell.appendChild(i);
            size_cell.appendChild(document.createTextNode("directory"));
        }
        else {
            var i = document.createElement("i");
            i.className = "glyphicon glyphicon-file";
            icon_cell.appendChild(i);
            size_cell.appendChild(document.createTextNode(bytesToSize(this.size)));
        }
        mtime_cell.appendChild(document.createTextNode(this.mtime));
    })
    table.appendChild(tbl_body);
    $("#panel-body").append(table);
}

function file(data) {
    file_location = '/files' + window.location.pathname;
    createDownloadBtn(file_location);
    $("#this-badge").html("This file");
    $("#search-field").attr("disabled", true);
    $("#search-btn").prop("disabled", true);
    $.ajax({
        type: 'HEAD',
        url: file_location,
        complete: function(xhr) {
            var contentType = xhr.getResponseHeader('Content-Type').split("/")[0];
            if (contentType == "text") {
                var pre = document.createElement("pre");
                pre.id = "fileContent";
                pre.className = "prettyprint";
                pre.style = "border: 0; background-color: transparent;";
                $("#panel-body").append(pre);
                $("#fileContent").load(file_location, function() {
                    prettyPrint();
                });
            }
            else if (contentType == "image") {
                var center = document.createElement("center");
                var img = document.createElement("img");
                img.src = file_location;
                center.appendChild(img);
                $("#panel-body").append(center);
            }
            else {
                var p = document.createElement("p");
                p.align = "center";
                p.innerHTML = "<br><br>Binary file<br><br>";
                $("#panel-body").append(p);
            }
            $("#loading").hide();
        },
        error: function(xhr, textStatus, errorThrown) {
            $("#loading").hide();
            alert("Failed");
        }
    });
}

function sendAndReceiveJson(jsonData, callback) {
    $.ajax({
        type: 'POST',
        url: '/api',
        data: JSON.stringify(jsonData),
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (!data.file)
                dir(data);
            else
                file(data);
            $("#loading").hide();
        },
        error: function(xhr, textStatus, errorThrown) {
            $("#loading").attr("src", "/static/" + xhr.status + ".jpg");
        }
    });
}

function getQueryString(field) {
    var href = window.location.href;
    var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
    var string = reg.exec(href);
    return string ? string[1] : null;
}

function listing() {
    createPathButtons();
    $(document).ready(function(){
        var jsonData = {
            "path": window.location.pathname,
            "search": ""
        };
        if (getQueryString("search") != null) {
            jsonData.search = getQueryString("search");
        }
        sendAndReceiveJson(jsonData, null);
    });
}
