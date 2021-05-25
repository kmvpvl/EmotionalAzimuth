var eaUser;
/**
 * 
 * @param {string} api - name of php 
 * @param {Object} data - object with data to send to server
 * @param {function} callback - callback function which will be called on success request
 */
function sendDataToServer(api, data, callback) {
	showLoading();
	var p = $.post(api + ".php",
	{
		username: $("#username").val(),
		password: $("#password").val(),
		data: data
	},
	callback);
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 401:
				clearInstance();
				showLoginForm();
			default:				
				showError(api + "<br>Description: " + data.status + ": " + data.statusText + ". " + data.responseText);
		}
	});
}

function recieveDataFromServer(data, status) {
	hideLoading();
	var ls = null;
	switch (status) {
		case "success":
			try {
				ls = JSON.parse(data);
				if (ls.result == 'FAIL') {
					showError("Application says: " + ls.description);
				} 
			} catch(e) {
				showError("Wrong data from server: " + e + " - " + data);
			}
			break;
		default:
			showError("Unsuccessful request: " + " - " + data);
	}
	return ls;
}

function receiveHtmlFromServer(data, status) {
	hideLoading();
	switch (status) {
		case "success":
			return data;
			break;
		default:
			clearInstance();
	}
	return null;
}

emotions = ['joy','trust','fear','surprise','sadness','disgust','anger','anticipation'];
function drawFlower (element, emotion) {
	var w = element.innerWidth();
	var R = w / 2;
	var r = R * 0.6;
	var N = 8;
	var s = '<svg class="flower" viewbox="-'+R+' -'+R+' '+w+' '+w+'" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="width:'+w+'px;height:'+w+'px;">';
	if (emotion) {
		for (i=0; i<N; i++) {
			var axis = parseFloat(emotion[emotions[i]]);
			if (!axis) R = w/2;
			else R = axis * w/2;
			r = R * 0.6;
			av = 2 * Math.PI * i / N;
			xv = Math.round(R * Math.sin(av));
			yv = -Math.round(R * Math.cos(av));
			ac1 = 2 * Math.PI * i / N + Math.PI/N;
			ac2 = 2 * Math.PI * i / N - Math.PI/N;
			xc1 = Math.round(r * Math.sin(ac1));
			xc2 = Math.round(r * Math.sin(ac2));
			yc1 = -Math.round(r * Math.cos(ac1));
			yc2 = -Math.round(r * Math.cos(ac2));
			s += '<path class="'+(axis?emotions[i]:'dotted')+'" d="M 0,0 L '+xc1+','+yc1+' Q '+xv+','+yv+' '+xc2+','+yc2+' L 0,0 z"></path>\n';
		}
	}
	s += '</svg>';
	element.html(s);
}
function drawLexeme(lex) {
    s = "<lexeme lexeme_id='"+lex.id+"'>";
    s += "<flower>"+drawFlower(lex.emotion)+"</flower>";
    s += "<normal>" + lex.lexeme + "</normal>";
    s += "<lang>" + lex.lang + "</lang>";
    s += "<stopword>" + (lex.stopword?lex.stopword:"") + "</stopword>";
	s += "<emotion>" + drawEmotion(lex.emotion) + "</emotion>";
    s += "</lexeme>";
    return s;
}
function drawDate (d, locale='ru-RU') {
	if (!d) return null;
	var options_date = {
		year: "2-digit",
		month: "2-digit",
		day: "2-digit"
	};
	var options_time = {
		hour: "2-digit",
		minute: "2-digit"
	};
	var cd = new Date();
	if (cd.getFullYear() == d.getFullYear()) {
		if (cd.getDate() == d.getDate() && cd.getMonth() == d.getMonth()) {
			return d.toLocaleTimeString(locale, options_time);			
		} else {
			return d.toLocaleDateString(locale, options_date);
		}
	} else {
		return d.toLocaleDateString(locale, options_date);
	}
}

class EAUser extends EventHandlerPrototype{
	constructor() {
		super();
		var th = this;
		sendDataToServer('apiGetOverviewInfo', null, function(data, status){
			var ls = recieveDataFromServer(data, status);
			if (ls && ls.result=='OK') {
				Object.assign(th, ls.data);
				th.fireEvent('change', null);
			} else {
				showError("Object EAUser damaged");
			}
		});
	}
}
class EAAssign extends EventHandlerPrototype {
	element = null;
	constructor(obj, element = null){
		super();
		Object.assign(this, obj);
		if (!element) this.element = $('<assign/>');
		else this.element = element;
		this.element[0].EAAssign = this;
	}
	static getHeader(){
		var s = '<assigns-header>';
		s += '<span>Task name</span>';
		s += '<span>Author</span>';
		s += '<span>Due</span>';
		s += '<span>Started</span>';
		s += '<span>Finished</span>';
		s += '</assigns-header>';
		return s;
	}
	draw(){
		var s = '';
		var due = new Date(this.due_date);
		var start = null;
		var finish = null;
		if (this.start_date) start = new Date(this.start_date);
		if (this.finish_date) finish = new Date(this.finish_date);
		s += '<assign-tools>'+'<i action="start" class="fa fa-play-circle" aria-hidden="true"></i>'+'</assign-tools>';
		s += '<set-name>'+this.set_name+'</set-name>';
		s += '<set-author>'+this.author+'</set-author>';
		s += '<assign-due-date>'+drawDate(due)+'</assign-due-date>';
		s += '<assign-start-date>'+drawDate(start)+'</assign-start-date>';
		s += '<assign-finish-date>'+drawDate(finish)+'</assign-finish-date>';
//		s += ''++'';
//		s += ''++'';
//		s += ''++'';
		this.element.html(s);
		this.element.click(function(){
			if($(this).hasClass('selected')) {
				$(this).removeClass('selected');
			} else {
				$(this).addClass('selected');
			}
		});
		var th = this;
		this.element.find('i[action]').click(function(event){
			th.fireEvent('action', {action: $(this).attr('action')});
			event.stopPropagation();
		});
	}
	doStart() {
		var th = this;
		sendDataToServer('apiStartAssign', {id: this.id}, function(data, status){
			var ls = recieveDataFromServer(data, status);
			if (ls && ls.result=='OK') {
				Object.assign(th, ls.data);
				th.fireEvent('started', null);
			} else {
				showError("Object EAAssign damaged");
			}
		});
	}
	drawAssessments(element){
		var s = '';
		for (const [ind, val] of Object.entries(this.assessments)){
			s = '<lexeme lexeme_id="'+val.lexeme_id+'"><flower></flower><lexeme-name>'+val.lexeme+'</lexeme-name></lexeme>';
			element.append(s);
			drawFlower($('lexeme[lexeme_id="'+val.lexeme_id+'"] > flower'), val);
		}
	}
}

class EASet extends EventHandlerPrototype {
	element = null;
	id = null;
	constructor(set_id, element = null){
		super();
		this.id = set_id;
		this.loadData();
		if (!element) this.element = $('<set/>');
		else this.element = element;
		this.element[0].EASet = this;
	}
	loadData(){
		var th = this;
		sendDataToServer('apiGetSet', {id: this.id}, function(data, status){
			var ls = recieveDataFromServer(data, status);
			if (ls && ls.result=='OK') {
				Object.assign(th, ls.data);
				th.fireEvent('update', null);
			} else {
				showError("Object EASet damaged");
			}
		});
	}
	draw(){
		var s = '';
		for (const [ind, val] of Object.entries(this.lexemes)){
			s += '<lexeme lexeme_id="'+val.id+'"><flower></flower><lexeme-name>'+val.lexeme+'</lexeme-name></lexeme>';
		}
		this.element.html(s);
	}
}
