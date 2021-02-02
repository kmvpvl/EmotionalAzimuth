<input id="filterIgnore" type="checkbox" checked data-toggle="toggle" data-on="evaluated" data-off="not eval" data-onstyle="success" data-offstyle="danger" data-width="140">
<input id="searchString" type="string" placeholder="Lexeme search..."/>
DraftsCount (количество оценок)
<input id="filterDraftCount" type="number" value="1" data-decimals="2" min="1" step="1"/>
<lexemes_list></lexemes_list>
<script>
var drafts;

$("#filterIgnore").bootstrapToggle();
$("#dlgModalEditLexemeEmotionIgnoreOnOff").bootstrapToggle();
$("#dlgModalEditLexemeEmotionIgnoreStopword").bootstrapToggle();
$("#filterIgnore").on('change', function(){
	//debugger;
	drawLexemes();
});
$("#searchString").on('input', function(){
	drawLexemes();
});
$("#filterDraftCount").on("change", function () {
	drawLexemes();
});

function clearLexemesList(){
	$('lexemes_list').html("");
}
var lexeme = new Object();
function saveLexeme(lex) {
	showLoading();
	var p = $.post("apiAssignEmotionToLexeme.php", {
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
		timezone: $("#timezone").val(),
		lexeme: lex },
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
                drawLexemes();
				break;
			default:
				clearLexemesList();
				showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 400:
			case 401:
				showLoginForm();
				break;
			default:;			
		}
		showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
	})
}
function showLexemeModal() {
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
	switch (lexeme.stopword) {
		case '':
			$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('off');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('disable');
			break;
	
		case '0':
			$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('on');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('off');
			break;

		case '1':
			$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('off');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('on');
			break;

		default:
			break;
	}
	$('#dlgModalEditLexemeEmotionIgnoreOnOff').change(function() {
		$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle($(this).prop('checked')?'enable':'disable'); 
		lexeme.stopword = $(this).prop('checked')?($('#dlgModalEditLexemeEmotionIgnoreStopword').prop('checked')?1:0):'';
	});
	$('#dlgModalEditLexemeEmotionIgnoreStopword').change(function() {
		lexeme.stopword = $('#dlgModalEditLexemeEmotionIgnoreOnOff').prop('checked')?($('#dlgModalEditLexemeEmotionIgnoreStopword').prop('checked')?1:0):'';
	});
	//debugger;
	$("flowers").html("");
	if (drafts[lexeme.id]) {
		for (const [ind, itm] of Object.entries(drafts[lexeme.id])) {
			$("flowers").append("<span>" + ind + drawFlower(itm.emotion) + "</span>");
		}
	}
	$("#dlgModalEditLexeme").modal('show');
}

function drawLexemes() {
	showLoading();
	//debugger;
	var p = $.post("apiGetEditorDictionary.php",
	{
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
		timezone: $("#timezone").val(),
		first_letters: $("#searchString").val(),
		ignore: $("#filterIgnore").is(':checked')?1:0,
		draft_count: $("#filterDraftCount").val(),
		count: 10
	},
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
			    ls = JSON.parse(data);
                if ('OK' == ls.result) {
					//debugger;
					clearLexemesList();
					for (const [index, item] of Object.entries(ls.data.lexemes)) {
                        $("lexemes_list").append(drawLexeme(item));
					};
					drafts = ls.data.drafts;
					$("lexeme > ignore:contains('1')").parent().addClass('stopword');
					$('lexeme').on ('click', function(event) {
						lexeme.id = event.currentTarget.attributes['lexeme_id'].nodeValue;
						lexeme.lexeme = $('lexeme[lexeme_id='+lexeme.id+'] > normal').text();
						lexeme.lang = $('lexeme[lexeme_id='+lexeme.id+'] > lang').text();
						lexeme.stopword = $('lexeme[lexeme_id='+lexeme.id+'] > ignore').text();
						lexeme.emotion = JSON.parse($('lexeme[lexeme_id='+lexeme.id+'] > emotion').text());
						showLexemeModal();
					});
                } else {
					showLoadingError(ls.description);
				}
				break;
			default:
				clearLexemesList();
				showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 401:
				clearLexemesList();
				showLoginForm();
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
		drawLexemes();
	});
})

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
		  <input id="dlgModalEditLexemeEmotionIgnoreOnOff" type="checkbox" checked data-toggle="toggle" data-on="on" data-off="off" data-onstyle="success" data-offstyle="danger" data-width="100">
		  <input id="dlgModalEditLexemeEmotionIgnoreStopword" type="checkbox" checked data-toggle="toggle" data-on="ignore" data-off="include" data-onstyle="danger" data-offstyle="success" data-width="100">
		  <span class="container-fluid">
			<div class="row">
				<div class="col-sm-3 joy">joy радость
				<input class="joy" modal_emotion="joy" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 trust">trust доверие
				<input class="trust" modal_emotion="trust" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 fear">fear страх
				<input class="fear" modal_emotion="fear" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 surprise">surprise удивление
				<input class="surprise" modal_emotion="surprise" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
			</div>
			<div class="row">
				<div class="col-sm-3 sadness">sadness печаль
				<input class="sadness" modal_emotion="sadness" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 disgust">disgust отвращение
				<input class="disgust" modal_emotion="disgust" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 anger">anger злость
				<input class="anger" modal_emotion="anger" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
				<div class="col-sm-3 anticipation">anticipation ожидание
				<input class="anticipation" modal_emotion="anticipation" type="number" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
				</div>
			</div>
			<flowers>

			</flowers>
		</span>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        <button type="button" dlg-button="btn-dlgModal-ok" class="btn btn-primary">Save</button>
      </div>
    </div>
  </div>
</div>