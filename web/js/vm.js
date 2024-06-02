function vm_monitor() {
    let vm_hardware = document.getElementById('vm_hardware');
    $.getJSON("./vm_hardware.json", function (data) {
        for (i = 0; i < data.length; i++) {
            if (data[i].vm_status) {
                $('#vm_hardware').append("<tr class='table-secondary'>" +
                    "<td colspan='10'>" + data[i].vm_status + "</td>" +
                    "</tr>");
            }
            else {
                $('#vm_hardware').append("<tr onclick='vm(" + i + ")' id=v" + i + " data-bs-toggle='modal' data-bs-target='#vm_exampleModal'>" +
                    "<td>" + data[i].vm_name + "</td>" +
                    "<td>" + data[i].disk_C_total + "</td>" +
                    "<td>" + (data[i].disk_C_total - data[i].disk_C_free).toFixed(1) + "</td>" +
                    "<td>" + data[i].disk_D_total + "</td>" +
                    "<td>" + (data[i].disk_D_total - data[i].disk_D_free).toFixed(1) + "</td>" +
                    "<td>" + data[i].disk_L_total + "</td>" +
                    "<td>" + (data[i].disk_L_total - data[i].disk_L_free).toFixed(1) + "</td>" +
                    "</tr>");
                if (((data[i].disk_C_total - data[i].disk_C_free) / data[i].disk_C_total) * 100 > 85) {
                    $("#v" + i).addClass('table-danger');
                }
                if (((data[i].disk_D_total - data[i].disk_D_free) / data[i].disk_D_total) * 100 > 85) {
                    $("#v" + i).addClass('table-danger');
                }
                if (((data[i].disk_L_total - data[i].disk_L_free) / data[i].disk_L_total) * 100 > 85) {
                    $("#v" + i).addClass('table-danger');
                }
            }
        }
    })
}

function vm(i) {
    let vm_name = $("#v" + i).find("td:eq(0)").html();
    let disk_C_total = $("#v" + i).find("td:eq(1)").html();
    let disk_C_usage = $("#v" + i).find("td:eq(2)").html();
    let disk_D_total = $("#v" + i).find("td:eq(3)").html();
    let disk_D_usage = $("#v" + i).find("td:eq(4)").html();
    let disk_L_total = $("#v" + i).find("td:eq(5)").html();
    let disk_L_usage = $("#v" + i).find("td:eq(6)").html();

    let disk_C_free = disk_C_total - disk_C_usage;
    let disk_D_free = disk_D_total - disk_D_usage;
    let disk_L_free = disk_L_total - disk_L_usage;

    let disk_C_warning = Math.round((disk_C_usage / disk_C_total) * 100);
    let disk_D_warning = Math.round((disk_D_usage / disk_D_total) * 100);
    let disk_L_warning = Math.round((disk_L_usage / disk_L_total) * 100);

    if (disk_C_warning > 85) {
        disk_C_color = 'rgb(227, 23, 13)';
    }
    else {
        disk_C_color = 'rgb(54, 162, 235)';
    }
    if (disk_D_warning > 85) {
        disk_D_color = 'rgb(227, 23, 13)';
    }
    else {
        disk_D_color = 'rgb(54, 162, 235)';
    }
    if (disk_L_warning > 85) {
        disk_L_color = 'rgb(227, 23, 13)';
    }
    else {
        disk_L_color = 'rgb(54, 162, 235)';
    }

    //
    let vmdisk_C = document.getElementById('disk_C').getContext('2d');
    disk_C = new Chart(vmdisk_C, {
        type: 'doughnut',
        data: {
            labels: ['已使用', '未使用'],
            datasets: [{
                data: [disk_C_usage, disk_C_free],
                backgroundColor: [
                    disk_C_color,
                    'rgba(0, 0, 0, 0.1)'
                ],
                // borderColor: [
                //     'rgba(54, 162, 235, 1)',
                //     'rgba(0, 0, 0, 0.3)'
                // ],
                borderWidth: 1,
                hoverOffset: 5
            }]
        },
        options: {
            legend: {
                display: true,
                labels: {
                    fontSize: 15
                }
            },
            plugins: {
                title: {
                    display: true,
                    text: vm_name + " disk C",
                    font: {
                        size: 20
                    }
                }
            }
        }
    });

    let vmdisk_D = document.getElementById('disk_D').getContext('2d');
    disk_D = new Chart(vmdisk_D, {
        type: 'doughnut',
        data: {
            labels: ['已使用', '未使用'],
            datasets: [{
                data: [disk_D_usage, disk_D_free],
                backgroundColor: [
                    disk_D_color,
                    'rgba(0, 0, 0, 0.1)'
                ],
                // borderColor: [
                //     'rgba(54, 162, 235, 1)',
                //     'rgba(0, 0, 0, 0.3)'
                // ],
                borderWidth: 1,
                hoverOffset: 5
            }]
        },
        options: {
            legend: {
                display: true,
                labels: {
                    fontSize: 15
                }
            },
            plugins: {
                title: {
                    display: true,
                    text: vm_name + " disk D",
                    font: {
                        size: 20
                    }
                }
            }
        }
    });

    let vmdisk_L = document.getElementById('disk_L').getContext('2d');
    disk_L = new Chart(vmdisk_L, {
        type: 'doughnut',
        data: {
            labels: ['已使用', '未使用'],
            datasets: [{
                data: [disk_L_usage, disk_L_free],
                backgroundColor: [
                    disk_L_color,
                    'rgba(0, 0, 0, 0.1)'
                ],
                // borderColor: [
                //     'rgba(0, 0, 0, 0.5)',
                //     'rgba(0, 0, 0, 0.5)'
                // ],
                borderWidth: 1,
                hoverOffset: 5
            }]
        },
        options: {
            legend: {
                display: true,
                labels: {
                    fontSize: 15
                }
            },
            plugins: {
                title: {
                    display: true,
                    text: vm_name + " disk L",
                    font: {
                        size: 20
                    }
                },
                outlabels: {
                    color: 'white',
                    stretch: 35,
                    borderRadius: 12,
                    borderWidth: 3,
                    display: true,
                    lineWidth: 2,
                    padding: 5,
                    textAlign: 'center',
                    font: {
                        resizable: true,
                        minSize: 16
                    }
                },
                datalabels: {
                    display: true,
                    color: '#fff',
                    font: {
                        size: 15
                    }
                }
            }
        }
    });
}

function vm_close(disk_C, disk_D, disk_L) {
    disk_C.destroy();
    disk_D.destroy();
    disk_L.destroy();
}