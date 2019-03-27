var loggedIn = false

$(document).ready(function(){
    $("#loginkonto-form").hide();
    $("#opretkonto-form").hide();
    $("#container").hide();

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
            $.post("http://vrp_twitter_reworked/close", JSON.stringify({}));
        }
    });
});

window.addEventListener("message", function(event) {
    if(event.data.action == "openTwitter"){
        $("#container").show();
        if(event.data.tweets != undefined){
            var tweets = event.data.tweets
            for(i=0;i<tweets.length;i++){
                var table = document.getElementsByTagName("table")[0];
                var newTweet = table.insertRow(1);

                var cel1 = newTweet.insertCell(0);
                var cel2 = newTweet.insertCell(1);
                var cel3 = newTweet.insertCell(2);

                cel1.innerHTML = tweets.account;
                cel2.innerHTML = tweets.tweet;
                cel3.innerHTML = tweets.date;
            }
        }
    } else if (event.data.action == "closeTwitter"){
        //$("#container").hide();
        togglePages("all")
    } else if (event.data.action == "login") {
        console.log(event.data.action + " - " + event.data.brugernavn)
        username = event.data.brugernavn
        twitterLogIn(username)
        $("#loginkonto-form").hide();
        togglePages("openall")
    } else if(event.data.action == "opret") {
        username = event.data.username
        twitterLogIn(username)
        $("#opretkonto-form").hide();
        togglePages("openall")
    }
});

function togglePages(page){
    if(page == "all"){
        $("#opretkonto-form").hide();
        document.getElementById('loginkonto-form').style.display='none'
        $("#twitter").hide();
        $("#headbuttons").hide();
        $("#tilbage").show();
        showTwitter = false
    }
    if(page == "twitter"){
        showTwitter = !showTwitter
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
        $("#opretsubmit").show();
    }
    if(page == "openall"){
        $("#twitter").show();
        $("#headbuttons").show();
        showTwitter = true
    }
}

function logOut(){
    if(username){
        loggedIn = false
        username = ""
        togglePages("openall")

        document.getElementById("username").innerHTML = "Logget ud"
    }
}

var username = ""

function twitterLogIn(usrname){
    if(usrname){
        loggedIn = true
        username = usrname

        document.getElementById("username").innerHTML = username
    }
}

function sendTweet(){
    if(loggedIn){
        var message = document.tweet.message.value;

        if(message != undefined && message != ""){

            if(message.length > 70){
                message = message.substring(0,70) + "\n" + message.substring(70,message.length)
            }

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
            cel3.innerHTML = dateTime;

            $.post("http://vrp_twitter_reworked/sendTweet", JSON.stringify({brugernavn:username, tweet: message, time: dateTime}));
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

    if(kode == retype) {

        if(usrname != " " && kode != " " && telefon != " "){
            $.post("http://vrp_twitter_reworked/opret", JSON.stringify({brugernavn: usrname, kode: kode, telefon: telefon}));
            togglePages("twitter")
            twitterLogIn(usrname)
        }
    } else{
        $("#retypeerror").show();
    }
}

function validateLogin(){
    var usrname = document.loginform.uname.value;
    var psword = document.loginform.psw.value;

    $.post("http://vrp_twitter_reworked/validateLogin", JSON.stringify({brugernavn:usrname, kode:psword}));
}
