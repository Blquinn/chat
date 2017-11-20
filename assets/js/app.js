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

var base_url = "http://localhost:4000";

var token = "";
var user_id = "";
var room_id = "";
var channel = null;


$(document).ready(function() {
  $('#bearer-form-input').click(function(e) {
    e.preventDefault();

    token = $('#bearer-token').val();

    $.ajax({
      url: base_url + "/api/rooms",
      headers: {
        "Authorization": "Bearer " + token
      },
      success: function(res) {
        let html_string = '';
        user_id = res.user;
        res.data.forEach(function(room) {
          html_string += `
            <a class="chat-room-link" href="#" data-room-id="${room.id}">${room.name}</a>
          `;
        })
        $('#conversations').html(html_string);
      },
      fail: function(stuff) {
        alert(stuff);
      }
    });
  });

  $('#conversations').delegate("a", "click", function() {
    room_id = $(this).data("room-id");
    console.log("Joining room ", room_id);
    $('#chat-log').html('');

    channel = socket.channel("room:" + room_id, {Authorization: "Bearer " + token});
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    console.log(channel);

    channel.on("new:msg", msg => {
      if (msg.body != 'ping') {
        console.log(msg);
        if (msg.user == user_id) {
          $('#chat-log').append(`
            <div class="message right">
              <span class="user">${msg.user}</span>
              <span class="body">${msg.body}</span>
            <div>
          `);
        } else {
          $('#chat-log').append(`
            <div class="message left">
              <span class="user">${msg.user}</span>
              <span class="body">${msg.body}</span>
            <div>
          `);
        }

      }
    })

    channel.on("user:entered", msg => {
      console.log(msg);
      $('#chat-log').append(`
        <div class="message user-enter">
          <span class="user">${msg.user} entered the room</span>
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

    channel.push("new:msg", {user: user_id, body: msg, room: room_id});
    
    $('#text-message').val('');
  });
});
