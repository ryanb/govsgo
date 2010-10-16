var moves = new Array();
var current_move = 0;
$(function() {
  if ($("#board").length > 0) {
    if ($("#board").attr("data-moves").length != "") {
      moves = $("#board").attr("data-moves").split("-");
    }
    current_move = moves.length;
    if ($("#board").attr("data-handicap") != "0") {
      current_move += 1
    }
    $("#board .e").live("click", function() {
      $.post(window.location.pathname + '/moves', {"move": $(this).attr("id"), "after": moves.length}, null, "script");
      // Show updating graphic here
    });
    $("#previous_move").click(function() {
      if (current_move > 0) {
        stepMove(-1);
      }
      return false;
    });
    $("#next_move").click(function() {
      if (current_move < moves.length) {
        stepMove(1);
      }
      return false;
    });
  }
});

function addMoves(new_moves) {
  $.each(new_moves.split("-"), function(index, move) {
    moves.push(move);
    if (current_move == moves.length-1) {
      stepMove(1);
    }
  });
}

function stepMove(step) {
  current_move += step;
  var color = (current_move % 2 ? "b" : "w");
  $.each(moves[step > 0 ? current_move-1 : current_move].match(/../g), function(index, position) {
    if (index == 0) {
      $("#" + position).attr("class", (step > 0 ? color : "e"));
    } else {
      $("#" + position).attr("class", (step > 0 ? "e" : color));
    }
  });
}
