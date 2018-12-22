<template>
    <div class="chat-container">
        <div class="chat-history">
            <div v-for="message in chatHistory" class="message-container" v-bind:class="message.from === currentUser ? 'right' : 'left'">
                <div class="from" v-if="message.from !== currentUser">{{message.from}}</div>
                <div class="speech-bubble">{{message.message}}</div>
            </div>
        </div>
        <input class="chat-message-txt" type="text" v-model="msgInput" v-on:keyup.enter="sendMessage()"/>
        <button v-on:click="sendMessage()">Send</button>
    </div>
</template>

<script lang="ts">
  import {Component, Prop, Vue} from 'vue-property-decorator';
  import ChatMessage from "types";

  @Component
    export default class ChatContainer extends Vue {
        public msgInput = '';

        @Prop() public currentUser!: string;

        public chatHistory: ChatMessage[] = [
          {message: 'Hello', from: 'terry'},
          {message: 'Hello again', from: 'larry'},
        ];

        private sendMessage() {
            if (this.msgInput === '') {
              return;
            }
            const msg: ChatMessage = {message: this.msgInput, from: this.currentUser};
            console.log(msg);
            this.chatHistory.push(msg);
            this.msgInput = '';
        }
    }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    .chat-container {
        margin-top: 1em;
        text-align: left;
        width: 30em;
    }

    .chat-history {
        overflow-y: scroll;
        background-color: aliceblue;
        height: 20em;
        padding: .5em;
    }

    .message-container {
        padding: .25em;
        margin: .25em;
    }

    .message {
        overflow-wrap: break-word;
        border-radius: 8px;
        padding: .25em;
        padding-left: .5em;
        padding-right: .5em;
    }

    .left > .from {
        font-size: .75em;
        margin-bottom: 0.5em;
        margin-left: .25em;
        margin-right: .25em;
    }

    .left {
        text-align: left;
    }

    .left > .message {
        background-color: #5cb85c;
    }

    .right > .message {
        background-color: #5bc0de;
    }

    .right {
        text-align: right;
    }

    .speech-bubble {
        display: inline-block;
        overflow-wrap: break-word;
        max-width: 95%;
        padding: .25em;
        padding-left: .5em;
        padding-right: .5em;
    }

    .right > .speech-bubble {
        position: relative;
        background: #00aabb;
        border-radius: .4em;
    }

    .right > .speech-bubble:after {
        content: '';
        position: absolute;
        right: 0;
        top: 50%;
        width: 0;
        height: 0;
        border: 0.406em solid transparent;
        border-left-color: #00aabb;
        border-right: 0;
        border-bottom: 0;
        margin-top: -0.203em;
        margin-right: -0.406em;
    }

    .left > .speech-bubble {
        position: relative;
        background: #00bb47;
        border-radius: .4em;
    }

    .left > .speech-bubble:after {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        width: 0;
        height: 0;
        border: 0.406em solid transparent;
        border-right-color: #00bb47;
        border-left: 0;
        border-top: 0;
        margin-top: -0.203em;
        margin-left: -0.406em;
    }
</style>
