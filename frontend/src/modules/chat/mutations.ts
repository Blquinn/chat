import {MutationTree} from "vuex";
import ChatMessage, {ChatState} from "@/modules/chat/types";

export const mutations: MutationTree<ChatState> = {
  messageRecieved(state, payload: ChatMessage) {
    state.chatHistory.push(payload);
  }
};
