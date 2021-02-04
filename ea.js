emotions = ['joy','trust','fear','surprise','sadness','disgust','anger','anticipation'];
function drawFlower (emotion, w=75) {
	R = w / 2;
	r = R * 0.6;
	N = 8;
	s = '<svg class="flower" viewbox="-'+R+' -'+R+' '+w+' '+w+'" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="width:'+w+'px;height:'+w+'px;">';
	if (emotion) {
		for (i=0; i<N; i++) {
			axis = emotion[emotions[i]];
			if (!axis) R = 0;
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
			s += '<path class="'+emotions[i]+'" d="M 0,0 L '+xc1+','+yc1+' Q '+xv+','+yv+' '+xc2+','+yc2+' L 0,0 z"></path>\n';
		}
	}
	s += '</svg>';
	return s;
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
