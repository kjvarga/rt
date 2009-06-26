$ = window.top.$;
$(function() {
  alert('calling method on frameset from header');
  window.top.doIt();
});
