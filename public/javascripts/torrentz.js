if (window.top.document.location.href != document.location.href
    && window.top.processTorrentzPage != undefined) {
  
  //var $ = window.top.$tz = window.top.$(document);
  var jQueryInit = window.top.jQueryInit,
      processTorrentzPage = window.top.processTorrentzPage;
  jQueryInit();
  //var $tz = $;
  $(function() {
    window.top.$tz = $(document);
    //$('div:has(> iframe), .cloud, .footer, .top ul, form.search').remove();
    window.top.processTorrentzPage(document.location.href);
    //alert($(document).find('.footer').html());
    //processTorrentzPage(document.location.href);
    //alert('done!');
  });
}