window.addEventListener("message", function(event){
    if(event.data.action == "init"){
        const resourceName = event.data.resourcename
    } 
});

var loggedIn = false

$(document).ready(function(){
    $("#loginkonto-form").hide();
    $("#opretkonto-form").hide();

    var showTwitter = true

    $("#tilbage").click(function(){
        togglePages("twitter")
    });

    $("#login").click(function(){
        togglePages("login")
    });

    $("#register").click(function(){
        togglePages("opret")
    });

    // Disable form submit
    $("form").submit(function() {
        return false;
    });

    // Escape key event + reset the page
    $(document).keyup(function(e) {
        if ( e.keyCode == 27 ) {
            $('#container').hide();
            $.post("http://" + resourceName + "escape", JSON.stringify({}));
        }
    });
});

window.addEventListener("message", function(event) {
    if(event.data.action == "openTwitter"){
        $("#container").show();
    }
    if(event.data.action == "closeTwitter"){
        togglePages("all")
        $("#container").hide();
    }
});

window.addEventListener("message", function(event) {
    if(event.data.action == "login") {
        username = event.data.username
    }
});

window.addEventListener("message", function(event) {
    if(event.data.action == "opret") {
        username = event.data.username
    }
});

function togglePages(page){
    if(page == "all"){
        $("#opretkonto-form").hide();
        document.getElementById('loginkonto-form').style.display='none'
        $("#twitter").hide();
        $("#headbuttons").hide();
        showTwitter = false
    }
    if(page == "twitter"){
        showTwitter = !showTwitter
        console.log("twitter")
        if(showTwitter){
            togglePages("all")
            $("#twitter").show();
            $("#headbuttons").show();
        } else {
            $("#twitter").hide();
            $("#headbuttons").hide();
        }
    }
    if(page =="login"){
        $("#loginkonto-form").show();
    }
    if(page =="opret"){
        togglePages("all")
        $("#opretkonto-form").show();
        $("#retypeerror").hide();
    }
}

var username = ""

function twitterLogIn(usrname){
    loggedIn = true
    username = usrname
    console.log(username)

    document.getElementById("username").innerHTML = username
}

function sendTweet(){
    if(loggedIn){
        var message = document.tweet.message.value;

        if(message != undefined && message != ""){

            var today = new Date();
            var date = today.getDate()+"/"+(today.getMonth()+1)+'/'+today.getFullYear();
            if(today.getMinutes() < 10){
                minutes = "0" + today.getMinutes();
            } else {
                minutes = today.getMinutes();
            }
            if(today.getSeconds() < 10){
                seconds = "0" + today.getSeconds();
            } else {
                seconds = today.getSeconds();
            }
            if(today.getHours() < 10){
                hours = "0" + today.getHours();
            } else {
                hours = today.getHours();
            }
            var time = hours + ":" + minutes + ":" + seconds
            var dateTime = time+' '+date

            var table = document.getElementsByTagName("table")[0];
            var newTweet = table.insertRow(1);

            var cel1 = newTweet.insertCell(0);
            var cel2 = newTweet.insertCell(1);
            var cel3 = newTweet.insertCell(2);

            cel1.innerHTML = username;
            cel2.innerHTML = message;
            cel3.innerHTML = dateTime
        }
    }
}

window.addEventListener("message", function(event){
    if(event.data.action == "updateTweets"){
        var tweets = document.getElementsByTagName("table").rows
        var alltweets = event.data.tweets
        var messages = []
        for(i=0;i<tweets.length;i++){
            messages[tweets.cells[1]]
        }
        for(a=0;a<alltweets.length;a++){
            if(messages[alltweets[a].message] == undefined){
                sendTweet(alltweets[a].message)
            }
        }
    }
});

function opretBruger(){
    var usrname = document.opret.brugernavn.value;
    var kode = document.opret.psword.value;
    var telefon = document.opret.telefonnr.value;
    var retype = document.opret.pswordretype.value;

    console.log(kode + " - " + retype)
    if(kode == retype) {

        if(usrname != " " && kode != " " && telefon != " "){
            var kode = sha256(kode)
            //$.post("http://" + resourceName + "opret", JSON.stringify({brugernavn: usrname, kode: kode, telefon: telefon}));
        }
        togglePages("twitter")
        twitterLogIn(usrname)
    } else{
        $("#retypeerror").show();
    }
}

function validateLogin(){
    var usrname = document.loginform.uname.value;
    var psword = document.loginform.psw.value;

    $.post("http://" + resourceName + "/validateLogin", JSON.stringify({brugernavn:usrname, kode:psword}));
}


async function sha256(message) {
    // encode as UTF-8
    const msgBuffer = new TextEncoder('utf-8').encode(message);                    

    // hash the message
    const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);

    // convert ArrayBuffer to Array
    const hashArray = Array.from(new Uint8Array(hashBuffer));

    // convert bytes to hex string                  
    const hashHex = hashArray.map(b => ('00' + b.toString(16)).slice(-2)).join('');
    return hashHex;
}