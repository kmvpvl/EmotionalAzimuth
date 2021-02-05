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
<script src="ea.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"></head>
<link href="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/css/bootstrap4-toggle.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/gh/gitbrent/bootstrap4-toggle@3.6.1/js/bootstrap4-toggle.min.js"></script>
<body>
<nav class="navbar navbar-expand-sm navbar-dark bg-dark ml-0">
	<a class="navbar-brand" href="#">EA
	</a>
	<!--button type="button" class="btn btn-success">Refresh</button-->
	<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
	</button>
	
	<div class="collapse navbar-collapse" id="navbarSupportedContent">
	<ul class="navbar-nav mr-auto">
		<li class="nav-item active">
			<a class="nav-link" instance="lexemes.php" id="menuDictionary" data-toggle="collapse" data-target=".navbar-collapse.show">My Lexemes</a>
		</li>
		<li class="nav-item ">
			<a class="nav-link" instance="editor.php" id="menuEditor" data-toggle="collapse" data-target=".navbar-collapse.show">Approve</a>
		</li>
		<li class="nav-item" >
			<a class="nav-link" instance="text.php" id="menuText" data-toggle="collapse" data-target=".navbar-collapse.show">Text</a>
		</li>
		<li class="nav-item" >
			<a class="nav-link" instance="statistics.php" id="menuStat" data-toggle="collapse" data-target=".navbar-collapse.show">Stat</a>
		</li>
	</ul>
	<ul class="navbar-nav lr-auto">
		<li class="nav-item dropdown">
			<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">User</a>
			<div class="dropdown-menu" aria-labelledby="navbarDropdown">
				<a class="dropdown-item" href="#">My settings</a>
				<a class="dropdown-item" href="#"></a>
				<a class="dropdown-item" href="#">Logout</a>
			</div>
		</li>
	</ul>
	</div>
</nav>
<script>
$(window).ready(function () {
	calcResize();
	showLoginForm();
	tryLogin();
	$("a[instance]").on ('click', function (event) {
		showLoading();
		$(".nav-item").removeClass("active");
		$(this).parent().addClass("active");
		$(".navbar-nav").collapse('hide');
		var p = $.post(event.target.attributes["instance"].value,
		{
			username: $("#username").val(),
			password: $("#password").val(),
			language: $("#language").val(),
			timezone: $("#timezone").val()
		},
		function(data, status){
			hideLoading();
			switch (status) {
				case "success":
					$("instance").html(data);
					break;
				default:
					clearInstance();
					hideLoading();
					showLoginForm();
			}
		});
		p.fail(function(data, status) {
			switch (data.status) {
				case 401:
					clearInstance();
					showLoginForm();
					showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
					break;
				default:				
					showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
			}
		})
	})
});
$(window).resize( function (){
    calcResize();
});
function calcResize() {
    $('instance').css('height', $(window).height() - $('instance').offset().top + "px");
    $("#errorLoadingMessage").offset({top: $(window).height()-$("#errorLoadingMessage").outerHeight()-$("nav").outerHeight(), left: 0});
    $("#loginform").offset({top: ($(window).height() - $("#loginform").outerHeight())/2, left: 0});
    $("#loadingSpinner").offset({top: ($(window).height() - $("#loadingSpinner").outerHeight())/2, left: ($("body").innerWidth() - $("#loadingSpinner").outerWidth())/2});
}
function showLoading() {
	$("#errorLoadingMessage").hide();
	$("#loadingSpinner").show();
}
function hideLoading() {
	$("#loadingSpinner").hide();
} 
function hideLoginForm() {
	$("#loginform").hide();
}
function showLoadingError(_text) {
	if (!$("#errorLoadingMessage").length) {
		$('body').append('<div id="errorLoadingMessage" class="alert alert-danger alert-dismissible"><button type="button" class="close" data-dismiss="alert">&times;</button><span></span></div>');
	}
	hideLoading();
	$("#errorLoadingMessage > span").html(_text);
    calcResize();
	$("#errorLoadingMessage").show();
}
function clearInstance() {
	$("instance").html("");
}
function showLoginForm() {
	$("#loginform").show();
	$("#submitLogin").on ('click', function (){
		tryLogin();
	})
}
function tryLogin() {
	if (!$("#username").val()) return;
	showLoading();
	hideLoginForm();
	var p = $.post("lexemes.php",
	{
		username: $("#username").val(),
		password: $("#password").val(),
		language: $("#language").val(),
		timezone: $("#timezone").val()
	},
	function(data, status){
		hideLoading();
		switch (status) {
			case "success":
				$("instance").html(data);
				break;
			default:
				clearInstance();
				showLoginForm();
		}
	});
	p.fail(function(data, status) {
		hideLoading();
		switch (data.status) {
			case 401:
				clearInstance();
				showLoginForm();
				showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
				break;
			default:				
				showLoadingError(data.status + ": " + data.statusText + ". " + data.responseText);
		}
	})
}
</script>
<instance>
</instance>
<div id="loadingSpinner" class="spinner-border"></div>
<div id="loginform">
	<div class="container">
	<div class="form-group">
		<label for="username">User name</label>
		<input type="text" placeholder="Enter Username" id="username" name="username" required value="">
	</div>
	<div class="form-group">
		<label for="password">Password</label>
		<input type="password" placeholder="Enter Password" id="password" required value=""></input>
	</div>
	<div class="form-group">
		<label for="timezone">Timezone</label>
		<input id="timezone" type="number" min="-12" max="12" class="digit" value="3"></input>
		<label for="language">Language</label>
		<select id="language" type="select"><option value="en" default="default">EN</option><option value="ru">RU</option></select>
	</div>
	<div class="form-group">		
		<button id="submitLogin">Login</button>
		<label>
		<input type="checkbox" checked="checked" name="remember"> Remember me</input>
		</label>
		<div class="container" style="background-color:#f1f1f1">
		<span class="psw">Forgot <a href="">password?</a></span>
	</div>
	</div>
	</div>
	
</div>
</body>
</html>