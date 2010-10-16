var moves = "";
var current_move = 0;
$(function() {
  if ($("#board").length > 0) {
    moves = $("#board").attr("data-moves").split("-");
    current_move = moves.length;
    $("#board .e").live("click", function() {
      // $(this).removeClass("e").addClass("b");
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
  var move_index = current_move-1 + step;
  var color = (move_index % 2 ? "w" : "b");
  $.each(moves[move_index].match(/../g), function(index, position) {
    if (index == 0) {
      $("#" + position).attr("class", (reverse ? "e" : color));
    } else {
      $("#" + position).attr("class", (reverse ? color : "e"));
    }
  });
  current_move += step;
}
