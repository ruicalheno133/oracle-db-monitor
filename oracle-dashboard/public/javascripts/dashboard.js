$(()=>{
    ajaxGETstatus();
    ajaxGETDashboardSessionGraph();
    ajaxGETStoragePie();
    ajaxGETMemoryPie();
    ajaxGETCPUBarGraph();
    ajaxGETSQLCommands();

    var sessions;
    var users = new Array();
    var tstamps = new Array();

    function updateUsers(values){
        for(i=0; i < values.length; i++){
            users.push(values[i])
        }
        while(users.length >= 10){
            (users).shift();
        }
    }

    function updateTstamps(values){
        for(i=0; i < values.length; i++){
            tstamps.push(values[i])
        }
        while(tstamps.length >= 10){
            (tstamps).shift();
        }
    }

    function ajaxGETstatus () {
        $.ajax({
            type: "GET",
            url: `/status`,
            success: result => {     
                $(`#statusTable`).empty()
                                 .html(result);
            },
            error: error => {

            }
          });
    }

    function ajaxGETStoragePie(){
        $.ajax({
            type: "GET",
            url: `/storage_pie`,
            success: result => {
                c3.generate({
                    bindto: '.storage_pie',
                    data: {
                        columns: [
                            ['Free Space', result.free_space],
                            ['Used Space', result.max_size - result.free_space],
                        ],
                        type: 'pie'
                    },
                    tooltip: {
                        format: {
                            value: function(value, ratio, id){
                                return value + ' Mb';
                            }
                        }
                    }
                })
            },
            error: error => {

            }
        });
    }

    function ajaxGETMemoryPie(){
        $.ajax({
            type: "GET",
            url: `/dashboard_memory`,
            success: result => {
                c3.generate({
                    bindto: '.dashboard_memory_pie',
                    data: {
                        columns:[
                            ['Free Space', result.free_space],
                            ['Used Space', result.used_space]
                        ],
                        type:'pie'
                    },
                    tooltip: {
                        format: {
                            value: function(value, ratio, id){
                                return value + ' Mb';
                            }
                        }
                    }
                })
            },
            error: error =>{

            }
        })
    }

    function ajaxGETCPUBarGraph(){
        $.ajax({
            type: "GET",
            url: `/dashboard_cpu`,
            success: result => {
                c3.generate({
                    bindto: '.dashboard_cpu_pie',
                    data: {
                        columns:[
                            ['Idle Time', result.idle_time],
                            ['Busy Time', result.busy_time],
                            ['IOWait Time', result.iowait_time]
                        ],
                        type:'bar',
                    },
                    tooltip: {
                        format: {
                            value: function(value, ratio, id){
                                return value + ' sec';
                            }
                        }
                    }
                })
            },
            error: error =>{

            }
        })
    }

    function ajaxGETDashboardSessionGraph(){
        $.ajax({
            type: "GET",
            url: `/dashboard_sessions_graph`,
            success: result=>{
                console.log(result.tstamps);
                sessions = c3.generate({

                    bindto: '.dashboard_sessions_graph',
                    data: {
                        x: 'x',
                        xFormat: '%Y-%m-%dT%H:%M:%SZ',
                        columns: [
                            ['x'].concat(result.tstamps),
                            ['users'].concat(result.sessions)
                        ]
                    },
                    axis: {
                        x: {
                            type: 'timeseries',
                            tick: {
                                format: '%d-%m-%Y %H:%M:%S'
                            }
                        }
                    }
                });
            }
        })
    }

    function refreshStatus() {
        ajaxGETstatus(); 
    }


    function ajaxGETSQLCommands() {
        $.ajax({
            type: "GET",
            url: `/sql_commands`,
            success: (result) => {
                $('#sql_commands').empty()
                $('#sql_commands').append("<tr><th>Comando</th><th>SQL ID</th><th>Schema</th></tr>")
                for(i = 0; i < result.commands.length && i < 4 ; i++){
                    $('#sql_commands').append("<tr><td width=\"60%\" height=\"60\"><div style=\"height: 100%; overflow:auto;\">"+result.commands[i].sql_fulltext+"</div></td><td>"+result.commands[i].sql_id+"</td><td>"+result.commands[i].schema_name+"</td></tr>")
                }
            }
        })
    }

    function refreshSessionsGraph() {
        $.ajax({
            type: "GET",
            url: `/dashboard_sessions_graph`,
            success: result => {
                updateTstamps(result.tstamps);
                updateUsers(result.sessions);
                sessions.load({
                    columns:[
                        ['x'].concat(tstamps),
                        ['users'].concat(users)
                    ],
                });
            }
        })
    }

    function refreshSQLCommands() {
        ajaxGETSQLCommands();
    }

    function refreshCPUBarGraph() {
        ajaxGETCPUBarGraph();
    }

    function refreshMemoryPie() {
        ajaxGETMemoryPie();
    }

    function refreshStoragePie() {
        ajaxGETStoragePie();
    }

    function refreshPage() {
        refreshStatus();
        //refreshSessionsGraph();
        ajaxGETDashboardSessionGraph();
        refreshSQLCommands();
        refreshCPUBarGraph();
        refreshMemoryPie();
        refreshStoragePie();
    }

    setInterval(function() {
        refreshPage();
    }, 60000)
});