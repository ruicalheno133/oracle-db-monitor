$(()=>{
    $('#tablespace-table tr').click(function() {
        ajaxGET('tablespaces', $(this).children(":first").text());
    });

    $('#users-table tr').click(function() {
        ajaxGET('users', $(this).children(":first").text());
    });


    function ajaxGET (table, id) {
        $.ajax({
            type: "GET",
            url: `/${table}/${id}`,
            success: result => {     
                c3.generate({
                    bindto: "#piechart",
                    data: {
                        columns: [
                            ['Free Space', result.maxsize - result.size],
                            ['Used Space', result.size],
                        ],
                        type : 'pie'
                    }
                })
            },
            error: error => {

            }
          });
    }
});