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
