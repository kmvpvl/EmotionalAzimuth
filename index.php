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
<body>
<script>
$(window).ready(function () {
    calcResize();
});
$(window).resize( function (){
    calcResize();
});
function calcResize() {
    $('instance').css('height', $(window).height() - $('instance').offset().top + "px");
    $("#errorLoadingMessage").offset({top: -$("#errorLoadingMessage").outerHeight(), left: 0});
}
function showLoading() {
	$("#errorLoadingMessage").hide();
	$("#loadingSpinner").show();
}
function hideLoading() {
	$("#loadingSpinner").hide();
} 
function showLoadingError(_text) {
    $('body').append('<div id="errorLoadingMessage" class="alert alert-danger alert-dismissible"><button type="button" class="close" data-dismiss="alert">&times;</button><span></span></div>');
	hideLoading();
	$("#errorLoadingMessage > span").html(_text);
    calcResize();
	$("#errorLoadingMessage").show();
}
function clearInstance() {
	$("instance").html = "";
}
</script>
<instance>
<?php
include 'lexemes.php';
?>
</instance>
<div id="loadingSpinner" class="spinner-border"></div>

</body>
</html>