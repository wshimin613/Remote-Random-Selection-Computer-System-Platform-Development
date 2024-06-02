var verify = JSON.parse(localStorage.getItem('user-info'));
if (verify) {
    function admin() {
        axios.get(`php/admin.php?username=${verify[1]}`)
            .then(identity => {
                const { data } = identity;
                if (data == 'admin') {
                    $("#ex2-tab-2").removeAttr("disabled");
                    $("#ex2-tab-3").removeAttr("disabled");
                }
            })
    }
}