from hangupsbot import HangupsBot, configure_logging
import appdirs,  asyncio, gettext, logging, logging.config, os, shutil, signal, sys, time

from flask import Flask
app = Flask(__name__)

bot = None

def init_bot():
    dirs = appdirs.AppDirs('hangupsbot', 'hangupsbot')
    default_log_path = os.path.join(dirs.user_data_dir, 'hangupsbot.log')
    default_cookies_path = os.path.join(dirs.user_data_dir, 'cookies.json')
    default_config_path = os.path.join(dirs.user_data_dir, 'config.json')
    default_memory_path = os.path.join(dirs.user_data_dir, 'memory.json')

    class Config:
        debug = True
        log = default_log_path
        config = default_config_path
        memory = default_memory_path
        cookies = default_cookies_path
        retries = 5

    configure_logging(Config)
    bot = HangupsBot(Config.cookies, Config.config, Config.retries, Config.memory)
    bot.run()

with app.app_context():
    init_bot()


@app.route('/')
def hello_world():
    if app.bot:
        return str(app.bot)
    else:
        return 'Bot not set'

