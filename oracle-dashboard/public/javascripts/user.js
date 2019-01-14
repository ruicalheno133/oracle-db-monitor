$(()=>{
    ajaxGET('user_tablespace', 'user_tablespace_table',window.location.pathname.split('/')[2])
    ajaxGET('user_role', 'user_role_table', window.location.pathname.split('/')[2])
    ajaxGET('role_user', 'role_user_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_datafiles','tablespace_datafiles_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_user','tablespace_user_table', window.location.pathname.split('/')[2])
    ajaxGETpie('datafiles_pie','datafile_pie', window.location.pathname.split('/')[2])
    ajaxGETDashboardPie('dashboard_pie','dashboard_pie',window.location.pathname.split('/')[2])
    ajaxGETDashboardSessionGraph('dashboard_session_graph','dashboard_session_graph',window.location.pathname.split('/'[2]))
    ajaxGETMemoryPie('dashboard_memory','dashboard_memory',window.location.pathname.split('/')[2])
    ajaxGETCPUPie('dashboard_cpu','dashboard_cpu',window.location.pathname.split('/')[2])

    var sessions;
    var users = new Array();
    var tstamps = new Array();

    function updateUsers(values){
        for(i=0; i < values.length; i++){
            users.push(values[i])
        }
        while(users.length >= 5){
            (users).shift();
        }
    }



    function updateTstamps(values){
        for(i=0; i < values.length; i++){
            tstamps.push(values[i])
        }
        while(tstamps.length >= 5){
            (tstamps).shift();
        }
    }

    function ajaxGET (req, table, id) {
        $.ajax({
            type: "GET",
            url: `/${req}/${id}`,
            success: result => {     
                $(`.${table}`).append(result);
            },
            error: error => {

            }
          });
    }

    function ajaxGETpie (req, table, id) {
        $.ajax({
            type: "GET",
            url: `/${req}/${id}`,
            success: result => {    
                c3.generate({
                    bindto: '.' + table,
                    data: {
                        columns: [
                            ['Free Space', result.max_size - result.size],
                            ['Used Space', result.size],
                        ],
                        type : 'pie'
                    },
                    tooltip: {
                        format: {
                            value: function (value, ratio, id) {
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

    function ajaxGETDashboardPie(req,table,id){
        $.ajax({
            type: "GET",
            url: `/dashboard_pie`,
            success: result => {
                c3.generate({
                    bindto: '.dashboard_pie',
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

    function ajaxGETMemoryPie(req,table,id){
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


    function ajaxGETCPUPie(req,table,id){
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
                        type:'pie'
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

    function ajaxGETDashboardSessionGraph(req,table,id){
        $.ajax({
            type: "GET",
            url: `/dashboard_sessions_graph`,
            success: result=>{
                sessions = c3.generate({
                    bindto: '.dashboard_sessions_graph',
                    data: {
                        x: 'x',
                        xFormat: '%H:%M:%S',
                        columns: [
                            ['x'].concat(result.tstamps),
                            ['users'].concat(result.sessions)
                        ]
                    },
                    axis: {
                        x: {
                            type: 'timeseries',
                            tick: {
                                format: '%H:%M:%S'
                            }
                        }
                    }
                });
            }
        })
    }


    setInterval(function(){
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
    },5000);

    setInterval(function(){
        $.ajax({
            type: "GET",
            url: `/sql_commands`,
            success: (result) => {
                $('#sql_commands').empty()
                $('#sql_commands').append("<tr><th>Comando</th><th>SQL ID</th><th>Schema</th></tr>")
                for(i = 0; i < result.commands.length && i < 5 ; i++){
                    $('#sql_commands').append("<tr><td>"+result.commands[i].sql_fulltext+"</td><td>"+result.commands[i].sql_id+"</td><td>"+result.commands[i].schema_name+"</td></tr>")
                }
            }
        })
    },5000)
});