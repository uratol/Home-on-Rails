var audio = new Audio();
function playAudio(string, lang) {
	if (typeof(lang)=='undefined') lang='ru';
	audio.src = 'api/tts/' + lang + '?s=' + encodeURIComponent(string);
	audio.play();
};

var recognizing = false;
var onEndUser;
var transcript = '';

var recognition = new webkitSpeechRecognition();
recognition.continuous = true;
recognition.lang = 'ru-RU';
recognition.interimResults = false;

recognition.onstart = function() {
	recognizing = true;
};

recognition.onerror = function(event) {
	if (event.error == 'no-speech') {
	}
	if (event.error == 'audio-capture') {
		console.log("onerror " + event.error);
		ignore_onend = true;
	}
	if (event.error == 'not-allowed') {
		console.log("onerror " + event.error);
		ignore_onend = true;
	}
};

recognition.onresult = function(event) {
	if ( typeof (event.results) == 'undefined') {
		recognition.onend = null;
		recognition.stop();
		return;
	}
	for (var i = event.resultIndex; i < event.results.length; ++i) {
		if (event.results[i].isFinal) {
			transcript += event.results[i][0].transcript;
			recognition.stop();
		};
	}
};

recognition.onend = function() {
	if (ignore_onend) {
		return;
	};
	recognizing = false;
	onEndUser(transcript);
};

function sendCommand(command) {
	$.ajax({
		url : "/speech/command",
		type : "POST",
		data : {
			transcript : command
		},
		success : function(resp) {
		}
	});
};

function startRecognizing(onEnd) {
	onEndUser = onEnd;
	if (recognizing) {
		recognizing = false;
		recognition.stop();
		return;
	}
	
    transcript = '';
	recognition.start();
	ignore_onend = false;
	start_timestamp = event.timeStamp;
};

