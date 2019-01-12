$(()=>{
    ajaxGET('user_tablespace', 'user_tablespace_table',window.location.pathname.split('/')[2])
    ajaxGET('user_role', 'user_role_table', window.location.pathname.split('/')[2])
    ajaxGET('role_user', 'role_user_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_datafiles','tablespace_datafiles_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_user','tablespace_user_table', window.location.pathname.split('/')[2])
    ajaxGETpie('datafiles_pie','datafile_pie', window.location.pathname.split('/')[2])
    ajaxGETDashboardPie('dashboard_pie','dashboard_pie',window.location.pathname.split('/'[2]))
    ajaxGETDashboardSessionGraph('dashboard_session_graph','dashboard_session_graph',window.location.pathname.split('/'[2]))

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

    function ajaxGETDashboardSessionGraph(req,table,id){
        $.ajax({
            type: "GET",
            url: `/dashboard_sessions_graph`,
            success: result=>{
                c3.generate({
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

});