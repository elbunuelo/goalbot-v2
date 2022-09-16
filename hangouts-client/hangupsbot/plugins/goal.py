import os
import plugins, requests, asyncio, json,logging

EN = 'en'
ES = 'es'

BOT_URL = os.environ['BOT_BASE_URL'] 
SUBSCRIPTIONS_URL = BOT_URL + '/{}/subscriptions'

def _initialise(bot):
    plugins.register_user_command(["seguir", "dejar", "follow", "unfollow", "suscripciones", "subscriptions"])

def _follow_match(bot, event, team, language):
    try:
        logging.info('Following Match in {}'.format(language))
        body = {
            'subscription': {
                'team': team,
                'service': 'Hangouts',
                'conversation_id': event.conv_id
            }
        }

        logging.info('Making request to {}'.format(SUBSCRIPTIONS_URL))
        response = requests.post(SUBSCRIPTIONS_URL.format(language), json=body)
        logging.info(response)

        body = response.json()
        logging.info(body)
        message = body['message']
        yield from bot.coro_send_message(event.conv_id, message)
    except:
        yield from bot.coro_send_message(event.conv_id, "Error")

def _unfollow_match(bot, event, team, language):
    try:
        logging.info('Unfollowing Match in {}'.format(language))
        body = {
            'subscription': {
                'team': team,
                'service': 'Hangouts',
                'conversation_id': event.conv_id
            }
        }

        response = requests.delete(SUBSCRIPTIONS_URL.format(language), json=body)

        body = response.json()
        logging.info(body)
        message = body['message']
        yield from bot.coro_send_message(event.conv_id, message)
    except Exception:
        logging.exception('')
        yield from bot.coro_send_message(event.conv_id, "Error")

def _list_subscriptions(bot, event, language):
    try:
        logging.info('Listing subscriptions in {}'.format(language))

        base_url = SUBSCRIPTIONS_URL.format(language)
        url = '{}/{}/{}'.format(base_url, 'Hangouts', event.conv_id)

        response = requests.get(url)

        body = response.json()
        logging.info(body)
        message = body['message']
        yield from bot.coro_send_message(event.conv_id, message)
    except Exception:
        logging.exception('')
        yield from bot.coro_send_message(event.conv_id, "Error")


def unfollow(bot, event, *args):
    yield from _unfollow_match(bot, event, ' '.join(args), EN)

def dejar(bot, event, *args):
    yield from _unfollow_match(bot, event, ' '.join(args), ES)

def follow(bot, event, *args):
    yield from _follow_match(bot, event, ' '.join(args), EN)

def seguir(bot, event, *args):
    yield from _follow_match(bot, event, ' '.join(args), ES)
