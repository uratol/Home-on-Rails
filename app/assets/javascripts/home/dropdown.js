$(document).on('turbolinks:load', function() {

    function showDropdownContent(elem){
        var left = elem.parent().offset().left;

        var rect = elem[0].getBoundingClientRect();

        if (left + elem.width() > window.innerWidth)
            left = window.innerWidth - rect.width;
        elem.css({left: left});
    }

    $('.dropbtn').click(function(){
        var dropdownContent = $(this).closest('.dropdown').find('.dropdown-content').first();
        dropdownContent.toggleClass('dropdown-show');
        if (dropdownContent.hasClass('dropdown-show'))
            showDropdownContent(dropdownContent);
    });

// Close the dropdown menu if the user clicks outside of it
    window.onclick = function(event) {
        if (!event.target.matches('.dropbtn'))
            $('.dropdown-show').removeClass('dropdown-show');
    }
});