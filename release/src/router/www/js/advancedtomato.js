function hideUpdate(version) {
    cookie.set('latest-update', version);
}

function notifications () {

    if (typeof nvram == 'undefined') { return false; }

    // Check for update
    if (typeof nvram.at_update !== "undefined" && nvram.at_update != '') {
        var n = cookie.get('latest-update');
        var lastUpdate = nvram['at_update'].replace('.', '');

        if (n < lastUpdate || n == null) {
            $(".content").prepend('<div class="alert info"><a href="#" class="close" data-update="' + nvram.at_update.replace('.','') + '">×</a>\
RipeTomato (<b>' + nvram.at_update + '</b>) is now available. <a target="_blank" href="https://github.com/Clarkmania/ripetomato/releases">Click here to find out more</a>.</div>');
        }
    }

    // Check if tomatoanon is configured
    if (typeof nvram.tomatoanon_answer !== "undefined") {          
        if (nvram.tomatoanon_answer != '1') {
            $('.content').prepend('<div class="alert warning"><b>Attention</b>: You did not configure <b>TomatoAnon project</b> setting.\
Please go to <a onclick="loadPage(\'admin-tomatoanon.asp\')" href="#">TomatoAnon configuration page</a> and make a choice.</div>');

        }           
    }

    // Not notification but gona borrow function :P
    if (typeof nvram.at_width !== "undefined") {

        if (nvram.at_width != 'fluid' && nvram.at_width != null) {
            $('#wrapper').css('width', nvram.at_width);
            $('body').addClass('fixedwidth');
        }	
    }
}

// Bind Navi etc.
function AdvancedTomato () {

    // Display Navigation
    navi();
    notifications();

    // Find current active link
    $('.navigation > ul > li').each(function(key) {

        if ($(this).hasClass('active')) {
            $(this).find('ul').slideDown('300');
            $(this).find('a:first').append('<i class="icon-chevron-down"></i>');
        } else {
            $(this).find('ul').slideUp(150);
            $(this).find('a:first i').remove();
        }	

    });

    // Bind for "back" state of browser
    $(window).hashchange(function(e) {

        // Prevent Missmatch on features page
        ((location.hash.replace('#', '') != '') ? loadPage(location.hash.replace('#', '')) : '');
        return false;

    });

    // Close click handler for updates
    $('.close').click(function() {
        var UpdateNTF = $(this).attr('data-update');
        if (UpdateNTF != null) { hideUpdate(UpdateNTF); }
        $(this).parent('.alert').hide();
    });

    // System Info box
    $('#system-ui').on('click', function() {

        if ($(this).hasClass('active')) {

            $('#system-ui').removeClass('active');	
            $('.system-ui').fadeOut(250);

        } else {

            $(this).addClass('active');	
            $('.system-ui').fadeIn(250);
            systemUI();

            $(document).click(function() {$('#system-ui').removeClass('active'); $('.system-ui').fadeOut(250); $(document).unbind('click'); });
        }

        return false;
    });

    // Navigation slides
    $('.navigation > ul > li > a').click(function() {

        if ($(this).parent('li').hasClass('active')) { return false; }

        $('.navigation > ul > li').removeClass('active').find('ul').slideUp('150');
        $('.navigation > ul > li').find('i').remove();
        $(this).parent('li').addClass('active');
        $(this).append('<i class="icon-chevron-down"></i>');
        $(this).closest('li').find('ul').slideDown('150');

        return false;
    });

    // Handle ajax loading
    $('.navigation li ul a, .header .links a[href!="#system"]').on('click', function(e) {
        loadPage($(this).attr('href'));
        return false;
    });

    // Handle Ajax Class Loading
    $('.ajaxwrap').on('click', '.ajaxload', function(e) {
        loadPage($(this).attr('href'));
        return false;
    });


    if (window.location.hash.match(/#/)) { loadPage(window.location.hash); } else { loadPage('#status-home.asp'); }
}


// Get status of router and fill system-ui with it
function systemUI () {

    $('.system-ui .datasystem').html('<div class="spinner"></div><br /><br />').addClass('align center');

    systemAJAX = new XmlHttp();
    systemAJAX.onCompleted = function (data, xml) {

        stats = {};
        try {
            eval(data);
        }
        catch (ex) {
            stats = {};
        }

        stats.wanstatus = '<a title="Go to Status Overview" href="#" onclick="loadPage(\'#status-home.asp\');">' + ((stats.wanstatus == 'Connected') ? '<span style="color: green;">' + stats.wanstatus + '</span>' : stats.wanstatus) + '</a>';
        $('.system-ui .datasystem').html(' <div class="pull-right"><small>(' + stats.uptime + ')</small></div> <h5>' + stats.routermodel + '</h5>'+
                                         '<hr><div class="leftblock">CPU:</div><div class="rightblock">' + stats.cpuload + '</div>'+
                                         '<div class="leftblock">RAM:</div><div class="rightblock">' + stats.memory + '<div class="progress"><div class="bar" style="width: ' + stats.memoryperc + '"></div></div></div>' +
                                         ((nvram.swap != null) ? '<div class="leftblock">SWAP:</div><div class="rightblock">' + stats.swap + '<div class="progress"><div class="bar" style="width: ' + stats.swapperc + '"></div></div></div>':'') +
                                         '<div class="leftblock">WAN:</div><div class="rightblock">' + stats.wanstatus + ' <small>(' + stats.wanuptime + ')</small></div>').removeClass('align center');
    }
    systemAJAX.get('js/status-data.jsx');
}


// Function preloader (Shows preloader close to cursor) 
function preloader (event) {

    if (event == 'start') {

        $('html,a,.btn').attr('style', 'cursor: wait !important');

    } else {

        $('html,a,.btn').removeAttr('style');

    }

}


// Ajax Function to load pages
function loadPage(Page) {

    // Fix refreshers when switching pages
    if (typeof (ref) != 'undefined') {
        ref.destroy();
    }

    // Some things that need to be done here =)
    Page = Page.replace('#', '');
    if (Page == 'status-home.asp' || Page == '/') { Page = 'status-home.asp'; }
    if (window.ajaxLoadingState) { return false; } else { window.ajaxLoadingState = true; }

    preloader('start');

    // Tomato XMLHTTP/AJAX
    TomatoAJAX = new XmlHttp();
    TomatoAJAX.onCompleted = function (resp, xml) {

        var dom = $(resp);
        var title = dom.filter('title').text();
        var html = dom.filter('content').html();
        $('title').text(window.routerName + title);
        $('h2.currentpage').text('/ ' + title); 
        $('.content .ajaxwrap').hide().html(html).fadeIn(400);

        // Push History
        if (history.pushState) { // Fix issue with IE9 or bellow
            window.history.pushState({"html":null,"pageTitle": window.routerName + title }, '#'+Page, '#'+Page);
        }


        // Go back to top
        $('html,body').scrollTop(0);

        // Handle Navigation
        $('.navigation li ul li').removeClass('active'); // Reset all

        var naviLinks = $(".navigation a[href='#" + Page + "']");
        $(naviLinks).parent('li').addClass('active');

        // Loaded, clear state
        window.ajaxLoadingState = false;

        // Custom file inputs
        $("input[type='file']").each(function() { $(this).customFileInput(); });
        preloader('stop');
    }

    // ERROR Handler
    TomatoAJAX.onError = function (x) {

        $('h2.currentpage').text('/ ERROR occured!');
        $('.content .ajaxwrap').hide().html('<h2>ERROR occured!<i class="icon-cancel" style="font-size: 20px; color: red; vertical-align: top;"></i></h2>\
<span style="font-size: 14px;">There has been error while loading a page, please review debug data bellow if this is isolated issue.<br />\
Otherwise file a bug report on <a target="_blank" href="https://github.com/Clarkmania/ripetomato/issues">Github</a>. <br /><br /><pre class="debug">' + x + '</pre><br /><a href="/">Refreshing</a> browser window might help.</span>').fadeIn(200);

        preloader('stop');
        // Loaded, clear state
        window.ajaxLoadingState = false;	
    }

    // Execute Prototype
    TomatoAJAX.get(Page);          

}

// Execute!
$(document).ready(function() { AdvancedTomato(); });

// $.browser jquery addon
(function(a){(jQuery.browser=jQuery.browser||{}).mobile=/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))})(navigator.userAgent||navigator.vendor||window.opera);
// Hash Change Plugin (Workaround browser issues)
(function($,e,b){var c="hashchange",h=document,f,g=$.event.special,i=h.documentMode,d="on"+c in e&&(i===b||i>7);function a(j){j=j||location.href;return"#"+j.replace(/^[^#]*#?(.*)$/,"$1")}$.fn[c]=function(j){return j?this.bind(c,j):this.trigger(c)};$.fn[c].delay=50;g[c]=$.extend(g[c],{setup:function(){if(d){return false}$(f.start)},teardown:function(){if(d){return false}$(f.stop)}});f=(function(){var j={},p,m=a(),k=function(q){return q},l=k,o=k;j.start=function(){p||n()};j.stop=function(){p&&clearTimeout(p);p=b};function n(){var r=a(),q=o(m);if(r!==m){l(m=r,q);$(e).trigger(c)}else{if(q!==m){location.href=location.href.replace(/#.*/,"")+q}}p=setTimeout(n,$.fn[c].delay)}$.browser.msie&&!d&&(function(){var q,r;j.start=function(){if(!q){r=$.fn[c].src;r=r&&r+a();q=$('<iframe tabindex="-1" title="empty"/>').hide().one("load",function(){r||l(a());n()}).attr("src",r||"javascript:0").insertAfter("body")[0].contentWindow;h.onpropertychange=function(){try{if(event.propertyName==="title"){q.document.title=h.title}}catch(s){}}}};j.stop=k;o=function(){return a(q.location.href)};l=function(v,s){var u=q.document,t=$.fn[c].domain;if(v!==s){u.title=h.title;u.open();t&&u.write('<script>document.domain="'+t+'"<\/script>');u.close();q.location.hash=v}}})();return j})()})(jQuery,this);
// Custom FileInputs (coded by http://prahec.com)
(function(e){e.fn.customFileInput=function(){var t=e(this).addClass("customfile-input").mouseover(function(){n.addClass("customfile-hover")}).mouseout(function(){n.removeClass("customfile-hover")}).focus(function(){n.addClass("customfile-focus");t.data("val",t.val())}).blur(function(){n.removeClass("customfile-focus");e(this).trigger("checkChange")}).bind("disable",function(){t.attr("disabled",true);n.addClass("customfile-disabled")}).bind("enable",function(){t.removeAttr("disabled");n.removeClass("customfile-disabled")}).bind("checkChange",function(){if(t.val()&&t.val()!=t.data("val")){t.trigger("change")}}).bind("change",function(){var t=e(this).val().split(/\\/).pop();var n="customfile-ext-"+t.split(".").pop().toLowerCase();i.html('<i class="icon-file"></i> '+t).removeClass(i.data("fileExt")||"").addClass(n).data("fileExt",n);r.text("Change")}).click(function(){t.data("val",t.val());setTimeout(function(){t.trigger("checkChange")},100)});var n=e('<div class="customfile"></div>');var r=e('<a class="btn btn-primary browse" href="#">Browse</a>').appendTo(n);var i=e('<span class="customfile-text" aria-hidden="true">No file selected...</span>').appendTo(n);if(t.is("[disabled]")){t.trigger("disable")}n.mousemove(function(r){t.css({left:r.pageX-n.offset().left-t.outerWidth()+20,top:r.pageY-n.offset().top-15})}).insertAfter(t);t.appendTo(n);return e(this)}})(jQuery)