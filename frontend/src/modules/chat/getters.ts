import {GetterTree} from "vuex";
import {ChatState} from "@/modules/chat/types";
import {RootState} from "@/models/RootState";

export const getters: GetterTree<ChatState, RootState> = {
  // currentUser(state): string {
  //   const {currentUser} = state;
  // }
};
