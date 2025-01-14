import { WebhookTypesEnum } from './enum'

export type WebhookObject = {
  object: 'whatsapp_business_account'
  entry: EntryObject[]
}

type EntryObject = {
  id: string
  changes: ChangesObject[]
}

type ChangesObject = {
  field: 'messages'
  value: ValueObject
}

export type ValueObject = {
  messaging_product: 'whatsapp'
  contacts: ContactObject[]
  messages: MessagesObject[]
  metadata: MetadataObject
}

type ContactObject = {
  wa_id: string
  profile: ProfileObject
}

type ProfileObject = {
  name: string
}

type MetadataObject = {
  display_phone_number: string
  phone_number_id: string
}

export type MessagesObject = {
  from: string
  id: string
  timestamp: string

  text?: TextObject

  type: WebhookTypesEnum
}

type TextObject = {
  body: string
}
