$(document).on('turbolinks:load', function() {
    $("[data-link]").click(function() {
        window.location = $(this).data("link")
    })
});
