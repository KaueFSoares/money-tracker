export const getCreateAccountMessage = (phone: string, name: string): string => {
  return JSON.stringify({
    messaging_product: 'whatsapp',
    to: phone,
    type: 'interactive',
    interactive: {
      type: 'button',
      body: {
        text: `Olá, ${name}, tudo bem? 😄 \n\nNão encontrei seu cadastro por aqui 🥹\n\nVamos criar a sua conta? ☺️`,
      },
      action: {
        buttons: [
          {
            type: 'reply',
            reply: {
              id: 'create_account',
              title: 'Criar Conta',
            },
          },
        ],
      },
    },
  })
}