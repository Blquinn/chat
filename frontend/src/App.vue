<template>
  <div id="app">
    <label for="username-txt">Username: </label>
    <input id="username-txt" type="text" v-model="username">
    <div id="chat-container"></div>
    <ChatContainer v-bind:currentUser="username"/>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import ChatContainer from './modules/chat/ChatContainer.vue';

@Component({
  components: {
    ChatContainer,
  },
})
export default class App extends Vue {
  private username = '';
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
