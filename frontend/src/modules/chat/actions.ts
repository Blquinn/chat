import {ActionTree} from "vuex";
import ChatMessage, {ChatState} from "@/modules/chat/types";
import {RootState} from "@/models/RootState";

export const actions: ActionTree<ChatState, RootState> = {
  sendMessage({ commit }): any {
    const msg: ChatMessage = {message: 'hello world', from: 'larry'};
    commit('Sent message', msg)
  }
};