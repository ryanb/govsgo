$(function() {
  $("#board .e").live("click", function() {
    $(this).removeClass("e").addClass("b");
    $.post(window.location.pathname + '/moves', {"move": $(this).attr("id")}, null, "script");
    // Show updating progress here
  });
});

