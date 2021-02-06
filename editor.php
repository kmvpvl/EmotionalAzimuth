<input id="filterIgnore" type="checkbox" checked data-toggle="toggle" data-on="evaluated" data-off="not eval" data-onstyle="success" data-offstyle="danger" data-width="140">
<input id="searchString" type="string" placeholder="Lexeme search..."/>
DraftsCount (количество оценок)
<input id="filterDraftCount" type="number" value="1" data-decimals="2" min="1" step="1" data-width="20"/>
<lexemes_list></lexemes_list>
<script>
var drafts = Object();

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
	//debugger;
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
			case 401:
				showLoginForm();
				break;
			default:;			
		}
		showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
	})
}
function showLexemeModal() {
	//debugger;
	$('#dlgModalEditLexemeTitle').text(lexeme.lexeme);
	$('#dlgModalEditLexemeFlower').html(drawFlower(lexeme.emotion, 200));
	$('[modal_emotion]').val(0);
	emotions.forEach(function (item, index) {
		$("[modal_emotion='"+item+"']").val(lexeme.emotion[item]?lexeme.emotion[item]:0);
	});
	$('[modal_emotion]').on ('input', function(event) {
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
			$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('on');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('on');
			break;

		default:
			break;
	}
	$('#dlgModalEditLexemeEmotionIgnoreOnOff').change(function() {
		$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle($(this).prop('checked')?'enable':'disable'); 
		lexeme.stopword = $(this).prop('checked')?($('#dlgModalEditLexemeEmotionIgnoreStopword').prop('checked')?1:0):null;
	});
	$('#dlgModalEditLexemeEmotionIgnoreStopword').change(function() {
		lexeme.stopword = $('#dlgModalEditLexemeEmotionIgnoreOnOff').prop('checked')?($('#dlgModalEditLexemeEmotionIgnoreStopword').prop('checked')?1:0):null;
	});
	//debugger;
	$("flowers").html("");
	if (drafts[lexeme.id]) {
		for (const [ind, itm] of Object.entries(drafts[lexeme.id])) {
			$("flowers").append("<span>" + drawFlower(itm.emotion, 30) + "<draft>" + ind + "</draft></span>");
		}
		$("draft").on('click', function(){
			//debugger;
			$('#dlgModalEditLexemeEmotionIgnoreOnOff').bootstrapToggle('on');
			$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('enable');
			idt = lexeme.id;
			Object.assign(lexeme, drafts[lexeme.id][$(this).text()]);
			lexeme.id = idt;
			$('#dlgModalEditLexemeFlower').html(drawFlower(lexeme.emotion, 200));
			//debugger;
			switch (lexeme.stopword) {
				case "0":
				case 0:
					$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('off');
					break;
				case "1":
				case 1:
					$('#dlgModalEditLexemeEmotionIgnoreStopword').bootstrapToggle('on');
					break;
			}
			for (var axis in lexeme.emotion) {
				$("[modal_emotion='"+axis+"']").val(lexeme.emotion[axis]);
			}
		});
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
		stopword: $("#filterIgnore").is(':checked')?1:0,
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
					$("lexeme > stopword:contains('1')").parent().addClass('stopword');
					$('lexeme').on ('click', function(event) {
						lexeme.id = event.currentTarget.attributes['lexeme_id'].nodeValue;
						lexeme.lexeme = $('lexeme[lexeme_id='+lexeme.id+'] > normal').text();
						lexeme.lang = $('lexeme[lexeme_id='+lexeme.id+'] > lang').text();
						lexeme.stopword = $('lexeme[lexeme_id='+lexeme.id+'] > stopword').text();
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
<?php
include ('editFlower.php');
?>
		<flowers>

		</flowers>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        <button type="button" dlg-button="btn-dlgModal-ok" class="btn btn-primary">Save</button>
      </div>
    </div>
  </div>
</div>