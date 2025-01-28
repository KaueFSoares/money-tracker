import { MessageType } from './message_type'

export type MessageDTO = {
  from: FromDTO;
  id: string;
  timestamp: string;
  text: string;
  businessPhoneNumberId: string;
}

export type FromDTO = {
  number: string;
  name: string;
}

export type SendMessageDTO = {
  to: ToDTO;
  type: MessageType;
}

export type ToDTO = {
  number: string;
  name: string;
  answerToId: string;
}