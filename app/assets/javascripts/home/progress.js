var progress, progressStartTime, progressTimerId = 0;
function progressSet(percent){
    if (!progress) return;
    if (percent >= 100){
        progress.hide();
    }
    else{
        var maxWidth = 200;
        if (percent <= 10) percent = 10; // always starts from 10%
        progress.width(1.0 * percent / 100 * maxWidth).show();
    }
}

function progressStart(estimatedDurationInSeconds){
    progressSet(0);
    progressStartTime = new Date();
    if (progressTimerId !== 0)
        clearInterval(progressTimerId);
    progressTimerId = setInterval(
        function(){
            var progressPercent = ((new Date()).getTime() - progressStartTime.getTime()) / 1000 / estimatedDurationInSeconds * 100;
            if (progressPercent >= 100) {
                progressPercent = 99;
                clearInterval(progressTimerId);
                progressTimerId = 0;
            }
            progressSet(progressPercent);
        }, 500);
}

function progressEnd(){
    if (progressTimerId !== 0)
        clearInterval(progressTimerId);
    progressSet(100);
}

$(document).on('turbolinks:load', function() {
    progress = $('#progress');
    progressSet(100);
});

