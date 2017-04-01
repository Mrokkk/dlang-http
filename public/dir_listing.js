$.when(
    $.getScript("/static/helpers.js"),
    $.Deferred(function(deferred) {
        $(deferred.resolve);
    })
).done(function() {
    $(document).ready(function(){
        createPathButtons();
        var getQueryString = function ( field, url ) {
            var href = url ? url : window.location.href;
            var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
            var string = reg.exec(href);
            return string ? string[1] : null;
        };
        var jsonData = {
            "path": window.location.pathname,
        };
        if (getQueryString("search") != null) {
            jsonData.search = getQueryString("search");
        }
        $.ajax({
            type: 'POST',
            url: '/api',
            data: JSON.stringify(jsonData),
            dataType: 'json',
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                var tbl_body = document.createElement("tbody");
                $.each(data, function() {
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
                $("table").append(tbl_body);
            }
        });
    });
});
