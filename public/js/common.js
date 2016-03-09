function httpGet()
{
    var theUrl = document.getElementById('mock_request_url');
    var urlInput = theUrl.value;
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "GET", urlInput, false );
    xmlHttp.send( null );
    document.getElementById('mock_data_response').value = xmlHttp.responseText;
}

function urlChanged() {
    var theUrl = document.getElementById('mock_request_url');
    var c = theUrl.value;
    theUrl.value = c;
    if (isURL(c) == false) {
       var getBtn = document.getElementById('get_button');
        getBtn.disabled = true;
    } else {
        var getBtn = document.getElementById('get_button');
        getBtn.disabled = false;
    }
}

function isURL(textval) {
    var urlregex = /^(https?|ftp):\/\/([a-zA-Z0-9.-]+(:[a-zA-Z0-9.&%$-]+)*@)*((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|([a-zA-Z0-9-]+\.)*[a-zA-Z0-9-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(:[0-9]+)*(\/($|[a-zA-Z0-9.,?'\\+&%$#=~_-]+))*$/;
    return urlregex.test(textval);
}

function getCloningData() {
    $("#form_form").attr("action","/mock/clone");
    $("#form_form").attr("method","get");
    document.getElementById("form_form").submit();
}