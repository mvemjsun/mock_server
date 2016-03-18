function validateJsonBody(input_area) {
    var contentType = $("#id_mock_content_type").val();

    if (contentType == "application/json;charset=UTF-8") {
        var jsonInput = $("#json_body");

        if (jsonInput.val().length > 0) {
            jsonInput.validateJSON({
                compress: false,
                reformat: true,
                'onSuccess': function (json) {
                    jsonInput.parent().removeClass('has-error').addClass('has-success');
                },
                'onError': function (error) {
                    jsonInput.parent().addClass('has-error');
                    xx = input_area.selectionStart;
                    yy = input_area.selectionEnd = xx + 100
                    jsonInput.selectRange(xx, yy);
                }
            });
        }
    }
    if (contentType == "text/xml") {

    }
    if (contentType == "text/html") {

    }
}

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
          </div class='form-group'>\
            <button class='btn btn-primary' type = 'button' row='xx' id= 'delete_button_xx' onclick= 'deleteRow(this)'> Delete</button>\
            <label id='status_row_xx' for='status_row_xx'>Pending</label><br/><br/>\
          <div>"

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

function validateBatchCloneData() {
    mock_names = $('input[name^="mock_name_"]');
    mock_urls = $('input[name^="mock_url_"]');
    mock_envs = $('select[name^="mock_environment_"]');
    var stateOK = true;

    mock_names.each(function(index) {
            if ($(this).val().trim().length == 0) {
                stateOK = false
            }
    });

    mock_urls.each(function(index) {
        if ($(this).val().trim().length == 0) {
            stateOK = false
        }
    });

    mock_envs.each(function(index) {
        if ($(this).val().trim().length == 0) {
            stateOK = false
        }
    });

    if (stateOK) {
        var mock_row_states = $('label[id^="status_row_"]');
        mock_row_states.each(function (index) {
            $(this).text('Processing ...');
        });
        $(':button').prop('disabled', true);
    }
    return stateOK;
}

function cloneRowOnSubmit(row) {
    if (validateBatchCloneData()) {

        mock_names = $('input[name^="mock_name_"]');
        mock_urls = $('input[name^="mock_url_"]');
        mock_envs = $('select[name^="mock_environment_"]');
        mock_row_states = $('label[id^="status_row_"]');

        var total_rows = mock_row_states.length;
        var count = 0;

        mock_names.each(function(index) {

            var mock_name = $(this).val();
            var mock_url= mock_urls[index].value;
            var mock_env= mock_envs[index].value;
            var mock_row_status= mock_row_states[index];

            $.ajax({
                method: "POST",
                url: "/mock/clone/batch",
                data: { name: mock_name, url: mock_url, mock_test_environment: mock_env}
            })
                .done(function (msg) {
//                    alert("Data processed: " + msg);
//                    mock_row_status.textContent = 'Done';
                    mock_row_status.textContent = msg;
                    switch (msg) {
                        case 'Updated':
                            mock_row_status.setAttribute('class','label label-info');
                            break;

                        case 'Error Updating':
                            mock_row_status.setAttribute('class','label label-warning');
                            break;

                        case 'Created':
                            mock_row_status.setAttribute('class','label label-success');
                            break;

                        case 'Error Creating':
                            mock_row_status.setAttribute('class','label label-danger');
                            break;

                    }
                    count = count + 1;
                    if (total_rows == count) {
                        $(':button').prop('disabled', false);
                    }
                });
        });


    } else {
        alert("Please supply all data. Mock Name and URL are required.");
    }
}