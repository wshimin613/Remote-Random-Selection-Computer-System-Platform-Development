function logout() {
    localStorage.clear();
    $(location).attr('href', 'index.html');
}

var verify = JSON.parse(localStorage.getItem('user-info'));
if (!verify) {
    $('#logout').remove("button");
}