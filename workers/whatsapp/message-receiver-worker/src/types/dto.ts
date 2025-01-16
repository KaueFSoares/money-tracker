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