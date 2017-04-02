$.when(
    $.getScript("/static/helpers.js"),
    $.Deferred(function(deferred) {
        $(deferred.resolve);
    })
).done(function() {
    listing();
});
