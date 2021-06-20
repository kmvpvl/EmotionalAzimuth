<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="application-name" content="EA">
<meta name="apple-mobile-web-app-title" content="EA">
<meta name="msapplication-starturl" content="/">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<link rel="stylesheet" href="ea.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="eventhandler.js"></script>
<script src="ea.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"></head>
<link href="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/css/bootstrap4-toggle.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/js/bootstrap4-toggle.min.js"></script>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<body>
<nav class="navbar navbar-expand-sm navbar-dark bg-dark ml-0">
	<a class="navbar-brand">EA
	</a>
	<!--button type="button" class="btn btn-success">Refresh</button-->
	<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
	</button>
	
	<div class="collapse navbar-collapse" id="navbarSupportedContent">
	<ul class="navbar-nav mr-auto">
		<li class="nav-item active">
			<a class="nav-link" instance="overview" id="menuOverview" data-toggle="collapse" data-target=".navbar-collapse.show">Overview</a>
		</li>
		<li class="nav-item">
			<a class="nav-link" instance="todo" id="menuDictionary" data-toggle="collapse" data-target=".navbar-collapse.show">To do</a>
		</li>
		<li class="nav-item ">
			<a class="nav-link" instance="editor" id="menuEditor" data-toggle="collapse" data-target=".navbar-collapse.show">My stat</a>
		</li>
	</ul>
	<ul class="navbar-nav lr-auto">
		<li class="nav-item dropdown">
			<a class="nav-link dropdown-toggle" href="#" id="menuUser" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">User</a>
			<div class="dropdown-menu" aria-labelledby="navbarDropdown">
				<a class="dropdown-item" href="#">My settings</a>
				<a class="dropdown-item" href="#"></a>
				<a class="dropdown-item" id="menuLogout" data-toggle="collapse" data-target=".navbar-collapse.show">Logout</a>
			</div>
		</li>
	</ul>
	</div>
</nav>
<script>
$(window).ready(function () {
//	showLoginForm();
	$("#username").val(localStorage.getItem("username")?localStorage.getItem("username"):"");
	$("#password").val(localStorage.getItem("password")?localStorage.getItem("password"):"");
	$("#menu-logout").on('click', function(){
		$("messages").hide();
		$("instance").html("");
		showLoginForm();
	});
	tryLogin();
	$("a[instance]").on ('click', function() {
		sendDataToServer($(this).attr("instance"), undefined,
		function(data, status){
			$("instance").html(receiveHtmlFromServer(data, status));
		});
	});
	$("#submitLogin").on ('click', function(){
		localStorage.setItem("username", $("#username").val());
		localStorage.setItem("password", $("#password").val());
	//		localStorage.setItem("", $("#").val());
	//		localStorage.setItem("", $("#").val());
		tryLogin();
	});
	$('#menuLogout').click(function(){
		showLoginForm();
	});
	$('[modal_emotion]').on('input', function(){
		//debugger;
		var e = new Object();
		for (const[i, v] of Object.entries(emotions)){
			e[v] = $('[modal_emotion="'+v+'"]').val();
		}
		drawFlower($('.modal-body > flower'), e);

	});
});
function showLoading() {
	$("loading-wait").show();
}
function hideLoading() {
	$("loading-wait").hide();
} 
function hideLoginForm() {
	$("login-form").hide();
}
/**
 * 
 */
function showError(_text) {
	var e = $('<error-message class="alert alert-danger alert-dismissible"><button type="button" class="close" data-dismiss="alert">&times;</button><span></span></error-message>');
	$('body').append(e);
	hideLoading();
	e.find('span').html(_text);
	$("error-message").show();
}
function clearInstance() {
	$("instance").html("");
}
function showLoginForm() {
	hideLoading();
	$("login-form").show();
}
function tryLogin() {
	if (!$("#username").val()) {
		hideLoading();
		showLoginForm();
		return;
	}
	eaUser = new EAUser();
	hideLoginForm();
	eaUser.on('change', function(u, o){
		$('#menuUser').text(u.currentUser.fullname);
		loadInstance();
	});
}
function loadInstance() {
	if ($('instance').html()) return;
	sendDataToServer("overview", undefined, 
	function(data, status){
		$("instance").html(receiveHtmlFromServer(data, status));
	});
}
function execAssign(assign_id) {
	$('instance').html('');
	sendDataToServer("execAssign", {id:assign_id}, 
	function(data, status){
		$("instance").html(receiveHtmlFromServer(data, status));
	});
}
</script>
<instance></instance>
<loading-wait class="spinner-border"></loading-wait>
<login-form>
	<div class="input-group">
		<div class="input-group-prepend">
		<span class="input-group-text">User name</span>
		</div>
		<input class="form-control" type="text" placeholder="Enter Username" id="username" name="username" required value="">
	</div>
	<div class="input-group">
		<div class="input-group-prepend">
		<span class="input-group-text">Password</span>
		</div>
		<input class="form-control" type="password" placeholder="Enter Password" id="password" required value=""></input>
		<div class="input-group-append">
		<button class="form-control btn btn-success" id="submitLogin">Login</button>
		</div>
	</div>
	<div class="input-group">		
		<div class="container" style="background-color:#f1f1f1">
		<span class="psw">Forgot <a href="">password?</a></span>
		</div>
	</div>
	</div>
</login-form>
<div class="modal fade" id="dlgLexemeModal" tabindex="-1" role="dialog" aria-labelledby="dlgLexemeModalLongTitle" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
		<span id="dlgLexemeID"></span>
        <h5 class="modal-title" id="dlgLexemeModalLongTitle">Import orders</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div id="dlgLexeme" class="modal-body">
		<flower></flower>
	  	<div id="dlgLexemeSliders">
		<span class="joy">joy радость</span>
		<input class="joy slider" modal_emotion="joy" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="trust">trust доверие</span>
		<input class="trust slider" modal_emotion="trust" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="fear">fear страх</span>
		<input class="fear slider" modal_emotion="fear" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="surprise">surprise удивление</span>
		<input class="surprise slider" modal_emotion="surprise" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="sadness">sadness печаль</span>
		<input class="sadness slider" modal_emotion="sadness" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="disgust">disgust отвращение</span>
		<input class="disgust slider" modal_emotion="disgust" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="anger">anger злость</span>
		<input class="anger slider" modal_emotion="anger" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		<span class="anticipation">anticipation ожидание</span>
		<input class="anticipation slider" modal_emotion="anticipation" type="range" value="0" data-decimals="2" min="0" max="1" step="0.1"/>
		</div>
      </div>
      <div class="modal-footer">
		<button id="btn-save-prev" type="button" class="btn btn-success" data-dismiss="">Save&amp;Prev</button>
    	<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
    	<button id="btn-save-next" type="button" class="btn btn-success" data-dismiss="">Save&amp;Next</button>
      </div>
    </div>
  </div>
</div>

</body>
</html>