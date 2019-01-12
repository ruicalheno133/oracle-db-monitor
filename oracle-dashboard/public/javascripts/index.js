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

            },
            error: error => {

            }
          });
    }
});