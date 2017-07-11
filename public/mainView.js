var currentLocation;

function bytesToSize(bytes) {
   var sizes = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
   if (bytes == 0) return '0B';
   var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
   return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
}

function formatCell(cell, proc) {
    cell.style = "vertical-align: middle;";
    cell.width = proc.toString() + "%"
}

function dirname(path) {
    return path.replace(/\/[^\/]*$/,'');
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
    var pathname = stripTrailingSlash(currentLocation);
    var dirList = pathname == "" || pathname == "/" ? [""] : pathname.split("/");
    var link = "/";
    dirList.forEach(function (entry) {
        if (entry == "") {
            entry = "/";
        }
        else {
            link += entry + "/";
        }
        var button = document.createElement("a");
        var self = link;
        button.addEventListener("click", function() {
            currentLocation = self != "/"
                ? currentLocation = stripTrailingSlash(self)
                : currentLocation = self;
            listing();
        }, false);
        button.href = "javascript:void(0);";
        button.role = "button";
        button.className = "btn btn-primary";
        button.text = entry;
        $("#path-buttons").append(button);
    });
}

function handleDir(data) {
    var table = document.createElement("table");
    table.setAttribute("data-link", "row");
    table.className = "table table-hover table-condensed";
    table.style = "margin-bottom: 0;";
    var tbl_body = document.createElement("tbody");
    $.each(data.entries, function() {
        var tableRow = tbl_body.insertRow();
        var iconCell = tableRow.insertCell();
        var nameCell = tableRow.insertCell();
        formatCell(iconCell, 2);
        formatCell(nameCell, 98);
        var a = document.createElement("a");
        a.href = "javascript:void(0);";
        var self = this;
        a.addEventListener("click", function() {
            if (self.filename == "..") {
                if (currentLocation != "/") {
                    currentLocation = dirname(currentLocation);
                }
            }
            else {
                currentLocation = self.filename.slice(1);
            }
            listing();
        }, false);
        a.innerHTML = basename(this.filename);
        nameCell.appendChild(a);
        if (this.isDir) {
            var i = document.createElement("i");
            i.className = "glyphicon glyphicon-folder-open";
            iconCell.appendChild(i);
        }
        else {
            var i = document.createElement("i");
            i.className = "glyphicon glyphicon-file";
            iconCell.appendChild(i);
        }
    })
    table.appendChild(tbl_body);
    $("#panel-body").append(table);
    $("#loading").hide();
}

function handleFile(data) {
    fileLocation = '/files' + currentLocation;
    $.ajax({
        type: 'HEAD',
        url: fileLocation,
        complete: function(xhr) {
            var contentType = xhr.getResponseHeader('Content-Type').split("/")[0];
            var contentSize = xhr.getResponseHeader('Content-Length');
            if (contentType == "text") {
                var pre = document.createElement("pre");
                pre.id = "fileContent";
                pre.className = "prettyprint";
                $("#panel-body").append(pre);
                $("#panel-body").attr("style", "");
                $("#fileContent").load(fileLocation, function() {
                    $("#loading").hide();
                });
            }
            else if (contentType == "image") {
                var center = document.createElement("center");
                var img = document.createElement("img");
                img.src = fileLocation;
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

function dispatcher(data) {
    $("#path-buttons").html("");
    $("#panel-body").html("<center><img id='loading' src='/static/loading.gif' align='middle'/></center>")
        .attr("style", "margin:0;padding:0;");
    createPathButtons();
    if (!data.file) {
        handleDir(data);
    }
    else {
        handleFile(data);
    }
}

function readDir(path, callback) {
    $.ajax({
        type: 'GET',
        url: '/api',
        data: JSON.stringify({"path": path}),
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            callback(data);
        },
        error: function(xhr, textStatus, errorThrown) {
            $("#loading").attr("src", "/static/" + xhr.status + ".jpg");
        }
    });
}

function listing() {
    $(document).ready(function(){
        readDir(currentLocation, dispatcher);
    });
}

$.when(
    $.Deferred(function(deferred) {
        $(deferred.resolve);
    })
).done(function() {
    currentLocation = "/";
    $("#menuButton").click(function() {
        $('#wrapper').toggleClass('toggled');
    });
    listing();
});

