angular.module('liveLogs', [])

    .controller('liveLogsController', function($http) {
        var vm = this;
        vm.liveLogs = [];
        vm.i = 0;
        vm.message = "";
        function logs() {
            vm.liveLogs = [];
            $http.get('/mock/api/requestlog/recent')
                .then(function(response) {
                    vm.liveLogs = [];
                    var json = response.data[0];
                    if (json['message'] == null) {
                        vm.message = "";
                        vm.i = 0;
                        response.data.forEach(function(array_item){
                            console.log(array_item.request_url);
                            vm.liveLogs.push(
                                {
                                    serial_number: ++vm.i,
                                    id: array_item.id,
                                    request_http_verb: array_item.request_http_verb,
                                    request_url: array_item.request_url.substring(0,70),
                                    created_at: array_item.created_at,
                                    request_body: array_item.request_body.substring(0,20),
                                    request_query_string: array_item.request_query_string.substring(0,20)
                                }
                            )
                        });
                    } else {
                        vm.message = "There is no RECENT activity recorded as yet.";
                    }
                });
        }
        var listener = setInterval(logs,5000);
    });