var moves          = new Array();
var current_move   = 0;
var current_user   = null;
var current_player = null;
var pollTimer      = null;
var sound          = true;
var audioExtension = null;

$(function() {
  $(".pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });

  if ($("#board").length > 0) {
    setupGame();
  }
  $("#game_opponent_username").focus(function() {
    $("#game_chosen_opponent_user").attr("checked", "checked");
  });
});

function setupGame() {
  if ($("#board").attr("data-moves").length != "") {
    moves = $("#board").attr("data-moves").split("-");
  }
  current_move = moves.length;
  current_user = $("#board").attr("data-current-user");
  current_player = $("#board").attr("data-current-player");
  $("#board_spaces div").click(function() {
    if ($(this).hasClass("e") && current_move == moves.length && current_user == current_player && $("#board").attr("data-finished") != "true") {
      playMove($(this).attr("id"));
    }
  });
  $("#play_pass").click(function() {
    playMove("PASS");
    return false;
  });
  $("#play_resign").click(function() {
    playMove("RESIGN");
    return false;
  });
  $("#previous_move").click(function() {
    if (current_move > 0) {
      stepMove(-1, false);
    }
    return false;
  });
  $("#next_move").click(function() {
    if (current_move < moves.length) {
      stepMove(1, false);
    }
    return false;
  });
  $("#first_move").click(function() {
    while (current_move > 0) {
      stepMove(-1, true);
    }
    return false;
  });
  $("#last_move").click(function() {
    while (current_move < moves.length) {
      stepMove(1, true);
    }
    return false;
  });
  $("#sound_switch").click(function() {
    sound = !sound;
    if (sound) {
      $("#sound_switch img").attr("src", "/images/game/sound_on.png");
    } else {
      $("#sound_switch img").attr("src", "/images/game/sound_off.png");
    }
  });
  if ($("#board").attr("data-finished") != "true") {
    startPolling();
  }
}

function playMove(move) {
  $.post(window.location.pathname + '/moves', {"move": move, "after": moves.length}, null, "script");
}

function addMoves(new_moves, next_player) {
  $('.profile .details .turn').hide();
  if ($("#board").attr("data-finished") != "true") {
    $('.profile .details #turn_' + next_player).show();
  }
  $.each(new_moves.split("-"), function(index, move) {
    moves.push(move);
    if (current_move == moves.length-1) {
      stepMove(1, index != new_moves.split("-").length-1);
    }
  });
  current_player = next_player;
}

function stepMove(step, multistep) {
  current_move += step;
  var offset = $("#board").attr("data-handicap") > 0 ? 1 : 0;
  var color = (current_move + offset) % 2 ? "b" : "w";

  // Update move by adding or removing stones based on what is matched
  if (step > 0) {
    updateStones(color, moves[current_move-1], false, multistep);
  } else {
    updateStones(color, moves[current_move], true, multistep);
  }

  // Update status for passed/resigned
  $("#board .last").removeClass("last");
  $(".profile .status").text("");
  if (moves[current_move-1] == "PASS") {
    $("#" + color + "_status").text("passed");
    if (!multistep) {
      playSound("pass", 0.4);
    }
  } else if (moves[current_move-1] == "RESIGN") {
    $("#" + color + "_status").text("resigned");
    if (!multistep) {
      playSound("resign", 0.4);
    }
  } else if (current_move > 0) {
    $("#" + moves[current_move-1].substr(0, 2)).addClass("last");
  }
}

function updateStones(color, move, backwards, multistep) {
  if (move != "" && move != "PASS" && move != "RESIGN") {
    $.each(move.match(/../g), function(index, position) {
      if (index == 0) {
        // if (!backwards && !multistep) {
        //   playSound("stone2", 0.6);
        // }
        $("#" + position).attr("class", (backwards ? "e" : color));
      } else {
        $("#" + position).attr("class", (backwards ? color : "e"));
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
}

function resetPollTimer() {
  pollTimer = 1000;
}

function playSound(name, volume) {
  if (sound) {
    if (!audioExtension) {
      if (!!document.createElement("audio").canPlayType) {
        var audio = new Audio("");
        if (audio.canPlayType("audio/ogg") != "no" && audio.canPlayType("audio/ogg") != "") {
          audioExtension = ".ogg";
        } else if (audio.canPlayType("audio/mpeg") != "no" && audio.canPlayType("audio/mpeg") != "") {
          audioExtension = ".mp3";
        } else {
          audioExtension = "";
        }
      } else {
        audioExtension = "";
      }
    }
    if (audioExtension != "") {
      var audio = new Audio("/sounds/" + name + audioExtension);
      audio.volume = volume;
      audio.play();
    }
  }
}
