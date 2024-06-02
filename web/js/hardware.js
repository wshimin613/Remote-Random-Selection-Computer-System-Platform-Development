function monitor() {
    let hardware = document.getElementById('hardware');
    $.getJSON("./hardware.json", function (data) {
        for (i = 0; i < data.length; i++) {
            if (data[i].host_status) {
                $('#hardware').append("<tr class='table-secondary'>" +
                    "<td colspan='10'>" + data[i].host_status + "</td>" +
                    "</tr>");
            }
            else {
                if (data[i].ssd2_total == null) {
                    data[i].ssd2_total = 'X';
                    data[i].ssd2_usage = 'X';
                    data[i].ssd2_health = 'X';
                }
                $('#hardware').append("<tr onclick='host(" + i + ")' id=h" + i + " data-bs-toggle='modal' data-bs-target='#exampleModal'>" +
                    "<td>" + data[i].hostname + "</td>" +
                    "<td>" + data[i].ssd_total + "</td>" +
                    "<td>" + data[i].ssd_usage + "</td>" +
                    "<td>" + data[i].ssd_health + "</td>" +
                    "<td>" + data[i].ssd2_total + "</td>" +
                    "<td>" + data[i].ssd2_usage + "</td>" +
                    "<td>" + data[i].ssd2_health + "</td>" +
                    "<td>" + data[i].hdd_total + "</td>" +
                    "<td>" + data[i].hdd_usage + "</td>" +
                    "<td>" + data[i].hdd_health + "</td>" +
                    "</tr>");

                if ((data[i].ssd_usage / data[i].ssd_total) * 100 > 85) {
                    $("#h" + i).addClass('table-danger');
                }
                if ((data[i].hdd_usage / data[i].hdd_total) * 100 > 85) {
                    $("#h" + i).addClass('table-danger');
                }
                if ((data[i].ssd2_usage / data[i].ssd2_total) * 100 > 85) {
                    $("#h" + i).addClass('table-danger');
                }
            }
        }
    })
}

function host(i) {
    let hostname = $("#h" + i).find("td:eq(0)").html();
    let ssd_total = $("#h" + i).find("td:eq(1)").html();
    let ssd_used = $("#h" + i).find("td:eq(2)").html();
    let hdd_total = $("#h" + i).find("td:eq(7)").html();
    let hdd_used = $("#h" + i).find("td:eq(8)").html();
    let ssd_unused = (ssd_total - ssd_used);
    let hdd_unused = (hdd_total - hdd_used);
    let ssd_warning = Math.round((ssd_used / ssd_total) * 100);
    let hdd_warning = Math.round((hdd_used / hdd_total) * 100);

    if (ssd_warning > 85) {
        ssd_color = 'rgb(227, 23, 13)';
    }
    else {
        ssd_color = 'rgb(54, 162, 235)';
    }
    if (hdd_warning > 85) {
        hdd_color = 'rgb(227, 23, 13)';
    }
    else {
        hdd_color = 'rgb(54, 162, 235)';
    }

    let ssd_data = {
        labels: [
            '已使用',
            '未使用'
        ],
        datasets: [{
            label: 'My First Dataset',
            data: [ssd_used, ssd_unused],
            backgroundColor: [
                ssd_color,
                'rgba(0, 0, 0, 0.1)'
            ],
            hoverOffset: 5
        }]
    };
    let ssd_options = {
        radius: '100%',
        plugins: {
            title: {
                display: true,
                text: hostname + ' SSD',
                font: {
                    size: 20
                }
            }
        }
    }
    let myChart = document.getElementById('SSD').getContext('2d');
    ssd_doughnut = new Chart(myChart, {
        type: 'doughnut',
        data: ssd_data,
        options: ssd_options
    })

    let hdd_data = {
        labels: [
            '已使用',
            '未使用'
        ],
        datasets: [{
            label: 'My First Dataset',
            data: [hdd_used, hdd_unused],
            backgroundColor: [
                hdd_color,
                'rgba(0, 0, 0, 0.1)'
            ],
            hoverOffset: 5
        }]
    };
    let hdd_options = {
        radius: '100%',
        plugins: {
            title: {
                display: true,
                text: hostname + ' HDD',
                font: {
                    size: 20
                }
            }
        }
    }
    let myChart2 = document.getElementById('HDD').getContext('2d');
    hdd_doughnut = new Chart(myChart2, {
        type: 'doughnut',
        data: hdd_data,
        options: hdd_options
    })



    let ssd2_exist = $("#h" + i).find("td:eq(4)").html();
    if (ssd2_exist != 'X') {
        let ssd2_total = $("#h" + i).find("td:eq(4)").html();
        let ssd2_used = $("#h" + i).find("td:eq(5)").html();
        let ssd2_unused = (ssd2_total - ssd2_used);
        let ssd2_warning = Math.round((ssd2_used / ssd2_total) * 100);
        if (ssd2_warning > 85) {
            ssd2_color = 'rgb(227, 23, 13)';
        }
        else {
            ssd2_color = 'rgb(54, 162, 235)';
        }

        let ssd2_data = {
            labels: [
                '已使用',
                '未使用'
            ],
            datasets: [{
                label: 'My First Dataset',
                data: [ssd2_used, ssd2_unused],
                backgroundColor: [
                    ssd2_color,
                    'rgba(0, 0, 0, 0.1)'
                ],
                hoverOffset: 5
            }]
        };
        let ssd2_options = {
            radius: '100%',
            plugins: {
                title: {
                    display: true,
                    text: hostname + ' SSD 2',
                    font: {
                        size: 20
                    }
                }
            }
        }
        let myChart3 = document.getElementById('SSD2').getContext('2d');
        ssd2_doughnut = new Chart(myChart3, {
            type: 'doughnut',
            data: ssd2_data,
            options: ssd2_options
        })
    }
    else {
        console.log('NO');
    }



}

function hardware_close(ssd_doughnut, hdd_doughnut) {
    ssd_doughnut.destroy();
    hdd_doughnut.destroy();
    ssd2_doughnut.destroy();
}