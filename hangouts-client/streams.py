import requests
import re
from bs4 import BeautifulSoup
streams_entry_point = 'https://raw.githubusercontent.com/mullafabz/Live/master/CASA.xml'


def remove_formatting(text):
    formatting_regex = r'\[[^\]]+\]'

    return re.sub(formatting_regex, '', raw_name)


def get_soup(link):
    response = requests.get(link)
    return BeautifulSoup(response.text, 'lxml')


link = None
soup = get_soup(streams_entry_point)
for channel in soup.find_all('channel'):
    raw_name = channel.find('name').get_text()
    name = remove_formatting(raw_name)

    if name == 'Live Football':
        link = channel.find('externallink').get_text()
        break

if link:
    soup = get_soup(link)

    for item in soup.find_all('item'):
        print(item)
