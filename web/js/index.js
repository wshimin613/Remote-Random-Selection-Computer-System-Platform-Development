$.when($.ready).then(function () {
    $('#nav').load('nav.html');
});

var verify = JSON.parse(localStorage.getItem('user-info'));
try {
    if (verify[0] == true) {
        window.history.forward(1);
    }
} catch { }

function main() {
    let account = document.getElementById('account').value;
    let password = document.getElementById('password').value;
    axios.get(`php/idcheck.php?id=${account}&pw=${password}`)
        .then(response => {
            const { data } = response;
            if (data[0] == true) {
                localStorage.setItem('user-info', JSON.stringify(data));
                $('#alert').removeClass("alert alert-danger").addClass('alert alert-success');
                $('#alert').html('認證成功！');
                console.log('asdfas');
                $(location).attr('href', 'rdp.html');
            }
            else {
                $('#alert').removeClass("alert alert-success").addClass('alert alert-danger');
                $('#alert').html(data);
            }
        })
}

/***function main() {
    let account = document.getElementById('account').value;
    let password = document.getElementById('password').value;
    axios({
        url: `php/idcheck.php?id=${account}&pw=${password}`,
        method: 'get',
        proxy: {
            host: 'localhost',
            port: 80
        }
    })
        .then(response => {
            const { data } = response;
            if (data[0] == true) {
                localStorage.setItem('user-info', JSON.stringify(data));
                $('#alert').removeClass("alert alert-danger").addClass('alert alert-success');
                $('#alert').html('認證成功！');
                $(location).attr('href', 'rdp.html');
            }
            else {
                $('#alert').removeClass("alert alert-success").addClass('alert alert-danger');
                $('#alert').html(data);
            }
        });
}***/