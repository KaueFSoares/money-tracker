import { SQSEvent, SQSHandler } from "aws-lambda";
import { MessageDTO } from "./types/dto";

const { GRAPH_API_TOKEN } = process.env

export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
  console.log("Received SQS event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const messageBody = record.body;
    console.log("Processing message:", messageBody);

    try {
      
      const message = JSON.parse(messageBody) as MessageDTO;
      console.log("Parsed data:", message);

      const response = await fetch(
        `https://graph.facebook.com/v21.0/${message.businessPhoneNumberId}/messages`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${GRAPH_API_TOKEN}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            messaging_product: 'whatsapp',
            to: message.from.number,
            text: { body: `Olá, ${message.from.name}! \n Parece que você ainda não está cadastrado, deseja criar sua conta? ` },
            context: {
              message_id: message.id,
            },
          }),
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