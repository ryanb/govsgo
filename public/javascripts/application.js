var moves = new Array();
var current_move = 0;
$(function() {
  if ($("#board").length > 0) {
    if ($("#board").attr("data-moves").length != "") {
      moves = $("#board").attr("data-moves").split("-");
    }
    current_move = moves.length;
    $("#board .e").live("click", function() {
      $.post(window.location.pathname + '/moves', {"move": $(this).attr("id"), "after": moves.length}, null, "script");
      // Show updating graphic here
    });
  }
});

function addMoves(new_moves) {
  $.each(new_moves.split("-"), function(index, move) {
    moves.push(move);
    if (current_move == moves.length-1) {
      stepMove(1, false);
    }
  });
}

function stepMove(step, reverse) {
  current_move += step;
  var color = (current_move % 2 ? "b" : "w");
  $.each(moves[current_move-1].match(/../g), function(index, position) {
    if (index == 0) {
      $("#" + position).attr("class", (reverse ? "e" : color));
    } else {
      $("#" + position).attr("class", (reverse ? color : "e"));
    }
  });
}
