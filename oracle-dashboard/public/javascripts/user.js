$(()=>{
    ajaxGET('user_tablespace', 'user_tablespace_table',window.location.pathname.split('/')[2])
    ajaxGET('user_role', 'user_role_table', window.location.pathname.split('/')[2])
    ajaxGET('role_user', 'role_user_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_datafiles','tablespace_datafiles_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_user','tablespace_user_table', window.location.pathname.split('/')[2])
    ajaxGETpie('datafiles_pie','datafile_pie', window.location.pathname.split('/')[2])

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
});