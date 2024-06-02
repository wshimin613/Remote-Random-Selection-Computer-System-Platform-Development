var verify = JSON.parse(localStorage.getItem('user-info'));

if (verify) {
    // function aaa() {
    //     axios.get(`php/admin.php?username=${verify[1]}`)
    //         .then(response => {
    //             const { data } = response;
    //             if (data == "admin") {
    //                 alert("OK");
    //             };
    //         });
    // }
    // 登入的使用者
    function user() {
        setInterval(get_user, 1000);
        click = setInterval(double_click, 1000);
    }

    function get_user() {
        axios.get(`php/login_user.php?username=${verify[1]}&auth=${verify[0]}`)
            .then(response => {
                const { data } = response;
                $('#user').html(data);
            });
    }

    function double_click() {
        //測試使用者不能重複點擊按鈕，會停留在載入頁面
        axios.get(`php/double_click.php?username=${verify[1]}&auth=${verify[0]}`)
            .then(response => {
                const { data } = response;
                if (data == 1) {
                    myFunction();
                }
                else if (data == 2) {
                    clearInterval(click);
                    download_page();
                }
                else {
                    clearInterval(click);
                    $('#word').removeAttr("style");
                    $('#openctrl').removeAttr("style");
                }
            });
    }

    function openctrl() {
        axios.get(`php/rdp.php?username=${verify[1]}&auth=${verify[0]}`)
            .then(response => {
                const { data } = response;
                console.log(data);
            });
        myFunction();
    }

    function myFunction() {
        clear = setInterval(progress, 500);
    }

    function progress() {
        $('#word').removeAttr("style");
        $('#progress').removeAttr("style");
        $('#openctrl').remove("button");
        // $('#word').html('正在為您開啟機器請稍後');
        axios.get(`php/user_status.php?username=${verify[1]}&auth=${verify[0]}`)
            .then(response => {
                const { data } = response;
                const progress = data[3];
                // status 1. 使用中 2. 實體機開機中 3. 虛擬機開機中 4. 確認機器中 5. 機器開啟錯誤
                switch (progress) {
                    case '0':
                        clearInterval(clear);
                        break;
                    case '6':
                        $('#progress-bar').css("width", "0%");
                        $('#progress-bar').html('0%');
                        clearInterval(clear);
                        $('#novm').removeAttr("style");
                        break;
                    case '5':
                        $('#progress-bar').css("width", "0%");
                        $('#progress-bar').html('0%');
                        clearInterval(clear);
                        // $('#word').html('啟動錯誤，稍後重新整理');
                        setTimeout(function () { location.reload(); }, 2000);
                        break;
                    case '4':
                        $('#progress-bar').css("width", "25%");
                        $('#progress-bar').html('25%');
                        break;
                    case '2':
                        $('#progress-bar').css("width", "50%");
                        $('#progress-bar').html('50%');
                        break;
                    case '3':
                        $('#progress-bar').css("width", "75%");
                        $('#progress-bar').html('75%');
                        break;
                    case '1':
                        $('#progress-bar').css("width", "100%");
                        $('#progress-bar').html('100%');
                        setTimeout(download_page, 500);
                        clearInterval(clear);
                        break;
                }
            });
    }

    function download_page() {
        $('#word').removeAttr("style");
        $('#download').removeAttr("style");
        $('#download_debian').removeAttr("style");
        $('#openctrl').remove("button");
        $('#progress').remove("div");
        $('#word').html('下載連線檔案');
    }

    function download() {
        axios.get(`php/add_firewall.php?username=${verify[1]}&auth=${verify[0]}`)
            .then(() => {
                window.open(`rdppkg/${verify[1]}.exe`);
            });
    }
    function download_debian() {
        axios.get(`php/add_firewall.php?username=${verify[1]}&auth=${verify[0]}`)
            .then(() => {
                window.open(`rdppkg/${verify[1]}`);
            });
    }
}
else {
    $(location).attr('href', 'index.html');
}