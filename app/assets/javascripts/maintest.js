var mins
var secs;

function setCookie(c_name,value,exdays) {
  var exdate=new Date();
  exdate.setDate(exdate.getDate() + exdays);
  var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
  document.cookie=c_name + "=" + c_value;
}

function getCookie(c_name) {
  var i,x,y,ARRcookies=document.cookie.split(";");
  for (i=0;i<ARRcookies.length;i++) {
  x=ARRcookies[i].substr(0,ARRcookies[i].indexOf("="));
  y=ARRcookies[i].substr(ARRcookies[i].indexOf("=")+1);
  x=x.replace(/^\s+|\s+$/g,"");
  if (x==c_name){
    return unescape(y);
    }
  }
}

function delCookie(name) {
  var exdate=new Date();
  document.cookie = name +
  '=; expires=Thu, 01-Jan-70 00:00:01 GMT;';
}

function dis(mins,secs) {
  var disp;
  if(mins <= 9) {
      disp = " 0";
  } else {
      disp = " ";
  }
  disp += mins + ":";
  if(secs <= 9) {
      disp += "0" + secs;
  } else {
      disp += secs;
  }
  return(disp);
}

function redo() {
  if (getCookie("mins") != null && getCookie("secs") != null) {
    mins = getCookie("mins");
    secs = getCookie("secs");
  }
  secs--;
  if(secs == -1) {
      secs = 59;
      mins--;
  }
  
  setCookie("mins", mins, null);
  setCookie("secs", secs, null);
  document.cd.disp.value = dis(mins,secs); // setup additional displays here.
  if((mins == 0) && (secs == 0)) {

    delCookie("mins");
    delCookie("secs");
    setCookie("finish", 1, null);
    //document.finishTestForm.submit();
    //window.alert("Time is up. Press OK to continue."); // change timeout message as required
    // window.location = "yourpage.htm" // redirects to specified page once timer ends and ok button is pressed
  } else {
    cd = setTimeout("redo()",1000);
  }
}

function des() {
  var check = confirm("Are you sure to submit this test?");
  if (check == false) {
    return check;
  }
  
  delCookie("finish");
  delCookie("mins");
  delCookie("secs");
  return check;
}
