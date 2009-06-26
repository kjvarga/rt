// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$ = window.top.$;
$(function() {
  alert('calling method on frameset from tz page');
  window.top.doIt();
});
