import { SQSEvent, SQSHandler } from 'aws-lambda'
import { DynamoDBClient, QueryCommand, QueryCommandInput } from '@aws-sdk/client-dynamodb'
import { MessageDTO, SendMessageDTO } from './types/dto'
import { SendMessageCommand, SQSClient } from '@aws-sdk/client-sqs'
import { MessageType } from './types/message_type'

const { REGION, SQS_QUEUE_URL } = process.env

const dynamoDbClient = new DynamoDBClient({ region: REGION });
const sqsClient = new SQSClient({ region: REGION })

const existsByPhone = async (phone : string): Promise<boolean> => {
  try {
    const params: QueryCommandInput = {
      TableName: "users",
      IndexName: "phone-index",
      KeyConditionExpression: "phone = :phone",
      ExpressionAttributeValues: {
        ":phone": { S: phone  },
      },
      Limit: 1,
    };

    const result = await dynamoDbClient.send(new QueryCommand(params));

    return !!(result.Items && result.Items.length > 0);
  } catch (error) {
    console.error("Error while looking for user:", error);
    throw new Error("Error while fetching DynamoDB");
  }
};

const startCreateAccountFlow = async (message: MessageDTO): Promise<void> => {
  const command = new SendMessageCommand({
    QueueUrl: SQS_QUEUE_URL,
    MessageBody: JSON.stringify({
      to: {
        number: message.from.number,
        name: message.from.name,
        answerToId: message.id
      },
      type: MessageType.CREATE_ACCOUNT_FIRST,
    } as SendMessageDTO)
  })

  const response = await sqsClient.send(command);

  console.log('Message sent to SQS:', JSON.stringify(response))
}

export const handler: SQSHandler = async (event: SQSEvent): Promise<void> => {
  console.log("Received SQS event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const messageBody = record.body;

    try {
      const message = JSON.parse(messageBody) as MessageDTO;

      if (!await existsByPhone(message.from.number)) {
        await startCreateAccountFlow(message);
        return
      }

      // handle transaction
      console.log("Not done yet")
    } catch (error) {
      console.error("Error processing message:", error);
    }
  }

}