$(()=>{
    ajaxGET('user_tablespace', 'user_tablespace_table',window.location.pathname.split('/')[2])
    ajaxGET('user_role', 'user_role_table', window.location.pathname.split('/')[2])
    ajaxGET('role_user', 'role_user_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_datafiles','tablespace_datafiles_table', window.location.pathname.split('/')[2])
    ajaxGET('tablespace_user','tablespace_user_table', window.location.pathname.split('/')[2])
    ajaxGETDatafilepie(window.location.pathname.split('/')[2]);

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

    function ajaxGETDatafilepie (id) {
        $.ajax({
            type: "GET",
            url: `/datafiles_pie/${id}`,
            success: result => {    
                c3.generate({
                    bindto: '.datafile_pie',
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
})