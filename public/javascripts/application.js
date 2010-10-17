var moves          = new Array();
var current_move   = 0;
var current_user   = null;
var current_player = null;
var pollTimer      = null;
$(function() {
  if ($("#board").length > 0) {
    if ($("#board").attr("data-moves").length != "") {
      moves = $("#board").attr("data-moves").split("-");
    }
    current_move   = moves.length;
    current_user   = $("#board").attr("data-current-user");
    current_player = $("#board").attr("data-current-player");
    $("#board .e").live("click", function() {
	  if (current_move == moves.length && current_user == current_player) {
	    $.post(window.location.pathname + '/moves', {"move": $(this).attr("id"), "after": moves.length}, null, "script");
      }
      // Show updating graphic here
    });
    $("#play_pass").click(function() {
      $.post(window.location.pathname + '/moves', {"move": "PASS", "after": moves.length}, null, "script");
      // Show updating graphic here
    });
    $("#play_resign").click(function() {
      $.post(window.location.pathname + '/moves', {"move": "RESIGN", "after": moves.length}, null, "script");
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
    $("#first_move").click(function() {
      while (current_move > 0) {
        stepMove(-1);
      }
      return false;
    });
    $("#last_move").click(function() {
      while (current_move < moves.length) {
        stepMove(1);
      }
      return false;
    });
    startPolling();
  }
  $("#game_opponent_username").focus(function() {
	$("#game_chosen_opponent_user").attr("checked", "checked");
  });
});

function addMoves(new_moves, next_player) {
  $('.profile .details .turn').hide();
  $('.profile .details #turn_' + next_player).show();
  $.each(new_moves.split("-"), function(index, move) {
    moves.push(move);
    if (current_move == moves.length-1) {
      stepMove(1);
    }
  });
  current_player = next_player;
  startPolling();
}

function stepMove(step) {
  current_move += step;
  var offset = ($("#board").attr("data-handicap") > 0 ? 1 : 0)
  var color  = (current_move + offset) % 2 ? "b" : "w";
  var move   = moves[step > 0 ? current_move-1 : current_move]
  $("#board .last").removeClass("last");
  if (move == "") {
	if (step > 0) {
	  if (color == "b") {
	    alert("Black passed.")
	  } else {
	    alert("White passed.")
	  }
	} else {
	  if (color == "b") {
	    alert("White passed.")
	  } else {
	    alert("Black passed.")
	  }
	}
  } else {
	$.each(move.match(/../g), function(index, position) {
	  if (index == 0) {
	    $("#" + position).attr("class", (step > 0 ? color : "e"));
	    if (current_move == moves.length) {
	      $("#" + position).addClass("last");
	    }
	  } else {
	    $("#" + position).attr("class", (step > 0 ? "e" : color));
	  }
	});
  }
}

function startPolling() {
  if (current_user != current_player) {
    resetPollTimer();
    setTimeout(pollMoves, pollTimer);
  }
}

function pollMoves() {
  // Slow down polling until it's 30 seconds apart
  if (pollTimer < 30000) {
    pollTimer += 1000;
  }
  $.getScript(window.location.pathname + '/moves?after=' + moves.length);
  // setTimeout(pollMoves, pollTimer);
}

function resetPollTimer() {
  pollTimer = 1000;
}
