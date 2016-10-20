(function($, undefined) {

$.clock = { version: "2.0.2", locale: {} };

t = new Array();
  
$.fn.clock = function(options) {
  var locale = {
    "it":{
      "weekdays":["Domenica","Lunedì","Martedì","Mercoledì","Giovedì","Venerdì","Sabato"],
      "months":["Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno","Luglio","Agosto","Settembre","Ottobre","Novembre","Dicembre"]
    },
    "en":{
      "weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],
      "months":["January","February","March","April","May","June","July","August","September","October","November","December"]
    },
    "es":{
      "weekdays":["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
      "months":["Enero", "Febrero", "Marzo", "Abril", "May", "junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    },
    "de":{
      "weekdays":["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"],
      "months":["Januar", "Februar", "März", "April", "könnte", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
    },
    "fr":{
      "weekdays":["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"],
      "months":["Janvier", "Février", "Mars", "Avril", "May", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    },
    "ru":{
      "weekdays":["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"],
      "months":["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    }
  };

  return this.each(function(){
    $.extend(locale,$.clock.locale);
    options = options || {};  
    
    options.timestamp = new Date( parseFloat($(this).data('time')) ); // options.timestamp || "systime";
    
    systimestamp = new Date();
    systimestamp = systimestamp.getTime();
    options.sysdiff = options.sysdiff || 0;
    if(options.timestamp!="systime"){
      mytimestamp = new Date(options.timestamp);
      options.sysdiff = options.timestamp - systimestamp;
    };
    options.langSet = options.langSet || "en";
    options.format = options.format || ((options.langSet!="en") ? "24" : "12");
    options.calendar = options.calendar || "true";
    options.seconds = options.seconds || "true";

    var addleadingzero = function(i){
      if (i<10){i="0" + i;}
      return i;    
    },
    updateClock = function(el,myoptions) {
      var el_id = $(el).attr("id");
      if(myoptions=="destroy"){ clearTimeout(t[el_id]); }
      else {
        mytimestamp = new Date();
        mytimestamp = mytimestamp.getTime();
        mytimestamp = mytimestamp + myoptions.sysdiff;
        mytimestamp = new Date(mytimestamp);

        var h=mytimestamp.getHours(),
        m=mytimestamp.getMinutes(),
        s=mytimestamp.getSeconds(),
        dy=mytimestamp.getDay(),
        dt=mytimestamp.getDate(),
        mo=mytimestamp.getMonth(),
        y=mytimestamp.getFullYear(),
        ap="",
        calend="";

        if(myoptions.format=="12"){
          ap=" AM";
          if (h > 11) { ap = " PM"; }
          if (h > 12) { h = h - 12; }
          if (h == 0) { h = 12; }
        }

        // add a zero in front of numbers 0-9
        h=addleadingzero(h);
        m=addleadingzero(m);
        s=addleadingzero(s);

        if(myoptions.calendar!="false") {
          if (myoptions.langSet=="en") {
            calend = "<div class='clockdate'>"+locale[myoptions.langSet].weekdays[dy]+', '+locale[myoptions.langSet].months[mo]+' '+dt+', '+y+"</div>";
          }
          else {
            calend = "<div class='clockdate'>"+locale[myoptions.langSet].weekdays[dy]+', '+dt+' '+locale[myoptions.langSet].months[mo]+' '+y+"</div>";
          }
        }
        $(el).html(calend+"<div class='clocktime'>"+h+":"+m+(options.seconds == "true"?":"+s:"")+ap+"</div>");
        t[el_id] = setTimeout(function() { updateClock( $(el),myoptions ); }, 1000);
      };

    };
      
    updateClock($(this),options);
  });
};

  return this;

})(jQuery);


clock_ready = function(){
	$("div#clock").clock( {format:"24"} );
};

$(document).on('turbolinks:load', clock_ready);
