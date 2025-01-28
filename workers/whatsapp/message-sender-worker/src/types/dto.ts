import { MessageType } from './message_type'

export type MessageDTO = {
  to: ToDTO;
  type: MessageType;
}

export type ToDTO = {
  number: string;
  name: string;
  answerToId: string;
}