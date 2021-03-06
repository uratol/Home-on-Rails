var refreshTimer = 0;
    refreshDelay = 5000;


function message(msg){
    $fl = $('#flash_container');
    if (msg) {
        $fl.find('#flash_messages').append('<div>' + msg + '</div>');
        $fl.show();
    }
    else
        $fl.hide();
}

var onAjaxError = function (request, ajaxOptions, thrownError) {
    progressEnd();
    if (thrownError)
	    message(thrownError+': '+request.responseText.substring(0,550));
};

function action_path(action){
    var path = window.location.pathname;
    if (path.substr(path.length - 1) !== '/')
        path += '/';
    path += action;
    return path;
}

function setBrightness(elem, brightness) {
	f = 'brightness(' + brightness + '%)';
	elem.css('-webkit-filter', f);
	elem.css('filter', f);
}

function stopRefresh(){
    if (refreshTimer !== 0){
        clearTimeout(refreshTimer);
        refreshTimer = 0;
    }
}

function doExit(){
    stopRefresh();
}

function doEnter(){
    refreshRequest();
    setRefreshInterval(refreshDelay);
}

function doChange(ent_id, value) {
    $.ajax({
        url: action_path('change'),
        method: 'POST',
        data: {
            root: $(".layout_container").attr('id'),
            id: ent_id,
            value: value
        },
        success: function (data) {
            refreshEntityes(data);
//            changing = false;
        },
        error: function (request, ajaxOptions, thrownError) {
//            changing = false;
            onAjaxError(request, ajaxOptions, thrownError);
        }
    });
}

var refreshTimeoutCallback = function(){
    refreshRequest();
    refreshTimer = setTimeout(refreshTimeoutCallback, refreshDelay);
}

function setRefreshInterval(interval){
    stopRefresh();
    refreshDelay = interval;
	refreshTimer = setTimeout(refreshTimeoutCallback, interval);
}

function refreshEntityes(entities) {
	entities.forEach(function(entity) {
		commonRefresh(entity);
	});
}

function commonRefresh(entity){
	var container = $('.entity').filter('#' + entity.id);

	var elem = container.find('#img' + entity.id);
	if (elem.attr('src') !== entity.img) {
		elem.attr('src', entity.img);
	}
	capt = container.find('#caption' + entity.id);
	if (capt !== null && entity.text !== undefined)
		capt.text(entity.text);
	if (entity.brightness !== undefined)
		setBrightness(elem, entity.brightness);
    if (entity.refresh_script !== undefined)
        eval(entity.refresh_script);
	container.trigger('entity:refresh', entity);	
}

function refreshRequest() {
    path = action_path('refresh');
    if (path !== '/refresh' && path.substring(0,6) !== '/show/')
      return;

    progressStart(5);
	$.ajax({
		// url: "/main/refresh?root=" + $(".layout_container").attr('id')
         url: action_path('refresh')
        ,method: 'POST'
		,success: function(data) {
             progressEnd();
             refreshEntityes(data);
			}
		,error: onAjaxError
	});

}

function arrangeLayout() {
	//lc.height(lc[0].scrollHeight);

	var maxRight = 0, maxBottom = 0, tmpInt;
	
	function calcChildrenBounds(e){
		e.children(':not(script)').each(function(){
			tmpInt = $(this).offset().top + $(this).outerHeight(true);
			if (tmpInt > maxBottom) { 
				maxBottom = tmpInt;
			}
	
			tmpInt = $(this).offset().left + $(this).outerWidth(true);
			if (tmpInt > maxRight) { 
				maxRight = tmpInt;
			}
			
			if (!$(this).hasClass('chart_div') ) {
				calcChildrenBounds($(this));
			}
		});
		
	}

    var container = $('.layout_container');
    container.each(function(){
		calcChildrenBounds($(this));
	});

    container.width(maxRight - container.offset().left);
    container.height(maxBottom - container.offset().top);
}

function act(elem, action){
    ajax(action_path(action), {id: elem.id})
}

function ajax(path, data){
    if(isDesignMode) return;
    $.ajax({
        url: path
        ,method: 'POST'
        ,data: data
        ,success: function(result) {
            if ($.isArray(result))
                refreshEntityes(result);
        }
        ,error: onAjaxError
    });
}

var ready = function(){

    $.ajaxSetup({
        headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
    });

	$(".at_click, .at_touchstart, .at_touchend").hover(function(){
        $(this).toggleClass('hover');
	});
	
	$(".at_touchstart").bind("touchstart mousedown", function(e){ e.preventDefault(); act(this, 'touchstart'); });
	$(".at_click, .at_dbl_click").click(function(){ act(this, 'click'); });
	$(".at_touchend").bind("touchend mouseup", function(e){ e.preventDefault(); act(this, 'touchend'); });

    $flash_container = $("#flash_container");
    $flash_container.find(".close").click(function () {
        $flash_container.find("#flash_messages").text('');
        $flash_container.hide();
        return false;
    });



	refreshRequest();

	if ($('.layout_container').length) {
		// setup height container by content
		// browser needs timeout for building elements
		setTimeout(function() {
		arrangeLayout();
		}, 500);
	}

    setRefreshInterval(refreshDelay);

    $(window).blur(function(){
        doExit();
    });
    $(window).focus(function(){
        doEnter();
    });
};

//$(document).on('page:change', ready);
$(document).on('turbolinks:load', ready);
