<?php

?>
<script>
var lexeme = new Object();
function drawLexeme(lex) {
    s = "<lexeme lexeme_id='"+lex.id+"'>";
    s += "<flower>"+drawFlower(lex.emotion)+"</flower>";
    s += "<normal>" + lex.lexeme + "</normal>";
    s += "<lang>" + lex.lang + "</lang>";
    s += "<ignore>" + (lex.ignore?lex.ignore:"") + "</ignore>";
	s += "<emotion>" + drawEmotion(lex.emotion) + "</emotion>";
    s += "</lexeme>";
    return s;
}
function saveLexeme(lex) {
	showLoading();
	var p = $.post("apiAssignEmotionToLexeme.php", lex,
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                //debugger;
				break;
			default:
				clearInstance();
				//showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 400:
				clearInstance();
				//showLoginForm();
				break;
			default:;			
		}
		showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
	})
}
function drawLexemes() {
	showLoading();
	var p = $.post("apiGetDictionary.php",
	{
		count: 10
	},
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                //debugger;
			    ls = JSON.parse(data);
                if ('OK' == ls.result) {
                    ls.data.forEach(function (item, index) {
                        $("instance").append(drawLexeme(item));
                    });
					$('lexeme').on ('click', function(event) {
						//alert(event.currentTarget.attributes['lexeme_id'].nodeValue);
						lexeme.id = event.currentTarget.attributes['lexeme_id'].nodeValue;
						lexeme.lexeme = $('lexeme[lexeme_id='+lexeme.id+'] > normal').text();
						lexeme.lang = $('lexeme[lexeme_id='+lexeme.id+'] > lang').text();
						lexeme.stopword = $('lexeme[lexeme_id='+lexeme.id+'] > ignore').text();
						lexeme.emotion = JSON.parse($('lexeme[lexeme_id='+lexeme.id+'] > emotion').text());
						$('#dlgModalEditLexemeTitle').text(lexeme.lexeme);
						$('#dlgModalEditLexemeFlower').html(drawFlower(lexeme.emotion, 200));
						$('[modal_emotion]').val(0);
						emotions.forEach(function (item, index) {
                        	$("[modal_emotion='"+item+"']").val(lexeme.emotion[item]?lexeme.emotion[item]:0);
						});
						$('[modal_emotion]').change (function(event) {
							axis = event.currentTarget.attributes['modal_emotion'].nodeValue;
							lexeme.emotion[axis] = $("[modal_emotion='"+axis+"']").val();
							$('#dlgModalEditLexemeFlower').html(drawFlower(lexeme.emotion, 200));
						});
						$("#dlgModalEditLexeme").modal('show');
					});
                }
				break;
			default:
				clearInstance();
				//showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 400:
				clearInstance();
				//showLoginForm();
				showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
				break;
			default:				
				showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
		}
	})
    
}

$(document).ready (function () {
	drawLexemes();
	$('[dlg-button="btn-dlgModal-ok"]').on('click', function () {
		saveLexeme(lexeme);
		$("#dlgModalEditLexeme").modal('hide');
	});
})

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
function drawEmotion (emotion) {
	s = '{';
	if (emotion) {
		for (i=0; i<N; i++) {
			if (i>0) s+=',';
			axis = emotion[emotions[i]];
			s += '"' + emotions[i] + '": '+axis;
		}
	}
	s += '}';
	return s;
}

</script>
<div class="modal fade" id="dlgModalEditLexeme" tabindex="-1" role="dialog" aria-labelledby="dlgModalLongTitle" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="dlgModalEditLexemeTitle">Modal title</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
		  <flower id="dlgModalEditLexemeFlower">

		  </flower>
		  <span class="container-fluid">
			<div class="row">
				<div class="col-sm-3 joy">joy
				<input class="joy" modal_emotion="joy" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 trust">trust
				<input class="trust" modal_emotion="trust" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 fear">fear
				<input class="fear" modal_emotion="fear" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 surprise">surprise
				<input class="surprise" modal_emotion="surprise" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-3 sadness">sadness
				<input class="sadness" modal_emotion="sadness" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 disgust">disgust
				<input class="disgust" modal_emotion="disgust" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 anger">anger
				<input class="anger" modal_emotion="anger" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 anticipation">anticipation
				<input class="anticipation" modal_emotion="anticipation" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
			</div>
		</span>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        <button type="button" dlg-button="btn-dlgModal-ok" class="btn btn-primary">Save</button>
      </div>
    </div>
  </div>
</div>