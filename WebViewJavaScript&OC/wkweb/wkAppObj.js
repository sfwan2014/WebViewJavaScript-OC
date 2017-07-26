
var appObj={};
appObj.login=function(userName, pwd){
    window.webkit.messageHandlers.user.postMessage('{\"type\":\"login\",\"username\":\"'+userName+'\", \"password\":\"'+pwd+'\"}')
};
