angular.module('liveLogs', [])

    .controller('liveLogsController', function($http) {
        var vm = this;
        vm.liveLogs = [];
        vm.i = 0;
        vm.message = "Waiting to get logs.";
        vm.refreshInterval = 5;

        vm.stopLogs = function stopRefresh() {
            advButton = document.getElementById('log_refresh_start_stop');
            classname = advButton.getAttribute('name');
            if (classname == 'stop_refresh') {
                clearInterval(vm.listener);
                advButton.setAttribute('name','start_refresh');
                advButton.value = 'Resume';
            } else {
                clearInterval(vm.listener);
                vm.listener = setInterval(logs, vm.refreshInterval * 1000);
                advButton.setAttribute('name','stop_refresh');
                advButton.value = 'Pause';
            }
        }

        vm.setRefreshInterval = function changeInterval() {
            if (!isNaN(vm.refreshInterval) && vm.refreshInterval >= 5) {
                clearInterval(vm.listener);
                vm.listener = setInterval(logs, vm.refreshInterval * 1000);
            }
        };

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

        vm.listener = setInterval(logs,vm.refreshInterval * 1000);
    });