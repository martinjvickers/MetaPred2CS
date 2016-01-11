var period = 20000;

function reloadPage(){
	location.reload(true);
	setTimeout("reloadPage()", period);
}

setTimeout("reloadPage()", period);
