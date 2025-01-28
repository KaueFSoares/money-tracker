import { SQSEvent, SQSHandler } from 'aws-lambda'
import { MessageDTO } from './types/dto'
import { getCreateAccountMessage } from './messages'
import { MessageType } from './types/message_type'

const { GRAPH_API_TOKEN, BUSINESS_PHONE_NUMBER_ID } = process.env

export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
  console.log("Received SQS event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const messageBody = record.body;
    console.log("Processing message:", messageBody);

    try {
      
      const message = JSON.parse(messageBody) as MessageDTO;
      console.log("Parsed data:", message);

      const body: string = (() => {
        switch (message.type) {
          case MessageType.CREATE_ACCOUNT_FIRST:
            return getCreateAccountMessage(message.to.number, message.to.name);

          default:
            return "";
        }
      })();

      const response = await fetch(
        `https://graph.facebook.com/v21.0/${BUSINESS_PHONE_NUMBER_ID}/messages`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${GRAPH_API_TOKEN}`,
            'Content-Type': 'application/json',
          },
          body: body,
        },
      )

      console.log("Response:", response);

      if (!response.ok) {
        throw new Error(`Failed to send message: ${response.statusText}`);
      }
      
    } catch (error) {
      console.error("Error processing message:", error);
    }
  }
}