setMenu = function () {

    function isMenuItemInMobileMenu(item){
        return (item.position().top > item.parent().position().top + 5);
    }


    var menuIcon = $('.menu-icon');
    var menu = $('.menu');
    menuIcon.hide();
    var lastItem = menu.children().last();
    var mobileMenuVisible = isMenuItemInMobileMenu(lastItem);
    if (mobileMenuVisible){
        var dropdownContent = menuIcon.find('.dropdown-content').first();
        if (!dropdownContent.children().length > 0)
            menu.children().clone(true, true).appendTo(dropdownContent);
    }
    menuIcon.toggle(mobileMenuVisible);
    if (mobileMenuVisible) {
        for (var i = 0; i < dropdownContent.children().length; i++) {
            dropdownContent.children().eq(i).toggle(isMenuItemInMobileMenu(menu.children().eq(i)));
        }
    }
};

var menuTimer;

$(document).on('turbolinks:load', function() {
    $('.menu>*').has('.active').addClass('active');

    setMenu();
    $(window).on("orientationchange load resize", function () {
        if (menuTimer) {
            clearTimeout(menuTimer)
        }
        menuTimer = setTimeout(setMenu, 50);
    });
});