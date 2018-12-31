window.onload = ()=>{
    c3.generate({
        bindto: "#chart",
        data: {
            x: 'x',
            xFormat: '%H:%M',
            columns: [
                ['x', '10:40', '10:45','10:50','10:55','11:00'],
                ['users', 30, 200, 100, 400, 150, 250]
            ]
        },
        axis: {
            x: {
                type: 'timeseries',
                tick: {
                    format: '%H:%M'
                }
            }
        }
    });

    c3.generate({
        bindto: "#piechart",
        data: {
            columns: [
                ['Free Space', 30],
                ['Used Space', 120],
            ],
            type : 'pie'
        }
    })
}