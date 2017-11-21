// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"
import $ from "jquery"

var base_url = 'http://' + window.location.host;

var token = "";
var user_id = "";
var room_id = "";
var channel = null;


$(document).ready(function() {

  $('#list-conversations-btn').click(function(e) {
    e.preventDefault();

    $.ajax({
      url: base_url + "/api/rooms",
      headers: {
        "Authorization": "Bearer " + $('#bearer-token').val()
      },
      success: function(res) {
        let html_string = '<ul>';
        user_id = res.user;
        res.data.forEach(function(room) {
          html_string += `
            <li><a class="chat-room-link" href="#" data-room-id="${room.id}">${room.name}</a></li>
          `;
        });
        html_string += '</ul>';
        $('#conversations').html(html_string);
      },
      error: function(error) {
        console.error(error);
        alert(JSON.stringify(error));
      }
    });
  });

  $('#room-entry-btn').click(function() {
    $.ajax({
      url: base_url + "/api/rooms",
      headers: {
        "Authorization": "Bearer " + $('#bearer-token').val()
      },
      method: 'POST',
      data: {
        name: $('#room-entry-txt').val()
      },
      success: function(res) {
        console.log(res);
        $('#peer-entry-room').val(res.data.id);
      },
      error: function(error) {
        console.error(error);
        alert(JSON.stringify(error));
      }
    });
  });

  $('#peer-entry-btn').click(function() {
    $.ajax({
      url: base_url + "/api/subscriptions",
      headers: {
        "Authorization": "Bearer " + $('#bearer-token').val()
      },
      method: 'POST',
      data: {
        room_id: $('#peer-entry-room').val(),
        username: $('#peer-entry-username').val()
      },
      success: function(res) {
        console.log(res);
        alert("Successfully added user to room");
      },
      error: function(error) {
        console.error(error);
        alert(JSON.stringify(error));
      }
    });
  });

  $('#conversations').delegate("a", "click", function() {
    room_id = $(this).data("room-id");
    console.log("Joining room ", room_id);
    $('#chat-log').html('');

    channel = socket.channel("room:" + room_id, {Authorization: "Bearer " + $('#bearer-token').val()});
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    console.log(channel);

    channel.on("new:msg", msg => {
      if (msg.body != 'ping') {
        console.log(msg);
        if (msg.user == user_id) {
          $('#chat-log').append(`
            <div class="message">
              <div class="right"><b>${msg.user}:</b> ${msg.body}</div>
            </div>
          `);
        } else {
          $('#chat-log').append(`
            <div class="message">
              <div class="left"><b>${msg.user}:</b> ${msg.body}<div>
            </div>
          `);
        }
        updateScroll()
      }
    })

    channel.on("user:entered", msg => {
      console.log(msg);
      $('#chat-log').append(`
        <div class="message user-enter">
          <span class="user"><b>${msg.user}</b> hath sojourned into thine holy chapel</span>
        <div>
      `);
    })

    channel.on("user:left", msg => {
      $('#chat-log').append(`
        <div class="message user-left">
          <span class="user">User left the room</span>
        <div>
      `);
    })

  });

  $('#send-button').click(function(e) {
    e.preventDefault();

    if (channel == null) {
      console.error("channel is null");
      return
    }

    let msg = $('#text-message').val();
    if (msg != '') {
      channel.push("new:msg", {user: user_id, body: msg, room: room_id});
      $('#text-message').val('');
    }
  });
});

function updateScroll(){
  var element = document.getElementById("chat-log");
  element.scrollTop = element.scrollHeight;
}
