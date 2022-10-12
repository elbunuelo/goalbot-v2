import os
import plugins, requests, asyncio, json,logging

EN = 'en'
ES = 'es'

BOT_URL = os.environ['BOT_BASE_URL']
SUBSCRIPTIONS_URL = BOT_URL + '/{}/subscriptions'
ALIASES_URL = BOT_URL + '/team_aliases'

def _initialise(bot):
    plugins.register_user_command([
        "seguir",
        "dejar",
        "follow",
        "unfollow",
        "suscripciones",
        "subscriptions",
        "alias"])

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

        request_url = SUBSCRIPTIONS_URL.format(language)
        logging.info('Making request to {}'.format(request_url))
        response = requests.post(request_url, json=body)
        logging.info(response)

        body = response.json()
        logging.info(body)
        message = body['message']
        yield from bot.coro_send_message(event.conv_id, message)
    except Exception:
        logging.exception('')
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
    except Exception as error:
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

def _add_alias(bot, event, args):
    try:
        logging.info('Adding alias {}'.format(args))
        if '::' in args:
            parts = args.split('::')
            logging.info('Creating alias {} for team {}'.format(parts[1], parts[0]))

            body = {
                'team_alias': {
                    'team_name': parts[0],
                    'alias': parts[1]
                }
            }

            response = requests.post(ALIASES_URL, json=body)
            body = response.json()
            message = body['message']
            yield from bot.coro_send_message(event.conv_id, message)
        else:
            yield from bot.coro_send_message(event.conv_id, "Error: Alias format is <team>::<alias>")


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

def suscripciones(bot, event, *args):
    yield from _list_subscriptions(bot, event, ES)

def subscriptions(bot, event, *args):
    yield from _list_subscriptions(bot, event, EN)

def alias(bot, event, *args):
    yield from _add_alias(bot, event, ' '.join(args))
