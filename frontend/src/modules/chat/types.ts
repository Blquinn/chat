import {Module} from "vuex";
import {RootState} from "@/models/RootState";
import {actions} from "@/modules/chat/actions";
import {mutations} from "@/modules/chat/mutations";
import {getters} from "@/modules/chat/getters";

export default interface ChatMessage {
  from: string;
  message: string;
}

// export const state: ChatState
export interface ChatState {
  msgInput: string;
  chatHistory: ChatMessage[];
}

const namespaced = true;
export const state: ChatState = {
  msgInput: '',
  chatHistory: [],
};
export const profile: Module<ChatState, RootState> = {
  namespaced,
  state,
  getters,
  actions,
  mutations,
};