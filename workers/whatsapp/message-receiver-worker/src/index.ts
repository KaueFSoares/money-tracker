import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'
import { WebhookObject } from './types/webhook'
import { HttpMethodsEnum, WebhookTypesEnum } from './types/enum'
import { SendMessageCommand, SQSClient } from '@aws-sdk/client-sqs'
import { MessageDTO } from './types/dto'

const { WEBHOOK_VERIFY_TOKEN, GRAPH_API_TOKEN, SQS_QUEUE_URL, REGION } = process.env

const sqsClient = new SQSClient({ region: REGION })

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  try {
    console.log('Incoming webhook event:', JSON.stringify(event))

    if (event.httpMethod === HttpMethodsEnum.GET) return handleGet(event)

    if (event.httpMethod === HttpMethodsEnum.POST) return handlePost(event)

    return {
      statusCode: 405,
      body: JSON.stringify({ message: 'Method Not Allowed' }),
    }
  } catch (error) {
    console.error('Error handling webhook:', error)
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Internal Server Error' }),
    }
  }
}

async function handlePost(
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> {
  const body = event.body
    ? (JSON.parse(event.body) as WebhookObject)
    : ({} as WebhookObject)

  console.log('Incoming webhook message:', JSON.stringify(body))

  const message = body.entry?.[0]?.changes?.[0]?.value?.messages?.[0]

  if (!message) {
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'No messages to process' }),
    }
  }

  const businessPhoneNumberId =
    body.entry?.[0]?.changes?.[0]?.value?.metadata?.phone_number_id

  const fromName =
    body.entry?.[0]?.changes?.[0]?.value?.contacts?.[0].profile?.name

  await fetch(
    `https://graph.facebook.com/v21.0/${businessPhoneNumberId}/messages`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${GRAPH_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        messaging_product: 'whatsapp',
        status: 'read',
        message_id: message.id,
      }),
    },
  )

  if (message?.type === WebhookTypesEnum.TEXT) {
    const command = new SendMessageCommand({
      QueueUrl: SQS_QUEUE_URL,
      MessageBody: JSON.stringify({
        from: {
          number: message.from,
          name: fromName
        },
        id: message.id,
        timestamp: message.timestamp,
        text: message.text?.body || '',
        businessPhoneNumberId,
      } as MessageDTO)
    })

    const response = await sqsClient.send(command);

    console.log('Message sent to SQS:', JSON.stringify(response))
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Webhook processed successfully' }),
  }
}

function handleGet(event: APIGatewayProxyEvent): APIGatewayProxyResult {
  const params = event.queryStringParameters || {}
  const mode = params['hub.mode']
  const token = params['hub.verify_token']
  const challenge = params['hub.challenge']

  if (mode === 'subscribe' && token === WEBHOOK_VERIFY_TOKEN) {
    console.log('Webhook verified successfully!')
    return {
      statusCode: 200,
      body: challenge || 'Webhook verified!',
    }
  }

  return {
    statusCode: 403,
    body: JSON.stringify({ message: 'Forbidden: Invalid verification token' }),
  }
}
