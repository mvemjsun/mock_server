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

function addMoreRow() {
    var new_row =
    "\
    <div class='row col-md-12' id='row_xx'>\
          <div class='form-group'>\
            <label class='control-label' for='mock_name_xx'>Mock Request Name</label>\
            <input class='form-control' name='mock_name_xx' placeholder='Mock name' type='text'>\
          </div>\
          <div class='form-group'>\
            <label class='control-label' for='mock_url_xx'>Mock URL</label>\
            <input class='form-control' name='mock_url_xx' placeholder='Mock URL' type='url'>\
          </div>\
          <div class='form-group'>\
            <label class='control-label' for='mock_environment_xx'>Test Env</label>\
            <select class='form-control' name='mock_environment_xx'>\
              <option id='integration'>integration</option>\
              <option id='production'>production</option>\
              <option id='quality'>quality</option>\
            </select>\
          </div>\
          <button class='btn btn-primary' type = 'button' row='xx' id= 'delete_button_xx' onclick= 'deleteRow(this)'> Delete</button><br/><br/>"
    var first_row=$('div[id^="row_"]').last().attr('id');
    var row_name_split_arr = (first_row.split("_"));
    var current_row_number = parseInt(row_name_split_arr[row_name_split_arr.length - 1]) + 1;
    var row = new_row.replace(/xx/g,current_row_number);

    $("#row_1").append(row)
}

function deleteRow(row) {
    var button_row = $(row).attr('row');
    var row = parseInt(button_row);
    $("#row_"+row).empty();
    $("#row_"+row).remove();
}