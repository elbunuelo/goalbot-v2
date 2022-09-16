import requests
from bs4 import BeautifulSoup

matches_url = "https://sportscentral.io/new-api/matches?timeZone=360&date=2020-11-14"

matches_headers = {
    'Host': 'sportscentral.io',
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate',
    'Origin': 'https://reddiit.soccerstreams.net',
    'Connection': 'keep-alive',
    'Referer': 'https://reddiit.soccerstreams.net/home',
    'DNT': '1',
    'Sec-GPC': '1',
    'Cache-Control': 'max-age=0',
}

response = requests.get(matches_url, headers=matches_headers)

match = response.json()[0]['events'][-1]
match_id = match['id']
event_link = match['redditEventLink']

stream_url = f'https://streams.101placeonline.com/streams-table/{match_id}/soccer?new-ui=1'
stream_headers = {
    'Host': 'streams.101placeonline.com',
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate',
    'Origin': 'https://reddiit.soccerstreams.net',
    'Connection': 'keep-alive',
    'Referer': event_link,
    'DNT': '1',
    'Sec-GPC': '1',
    'Cache-Control': 'max-age=0',
}

response = requests.get(stream_url, headers=stream_headers)

soup = BeautifulSoup(response.text, 'lxml')
if soup('table'):

    for stream in soup.select('tr[data-stream-link]', limit=10):
        link = stream['data-stream-link']
        columns = stream('td')
        quality = columns[4].find('span').get_text().strip()
        language = columns[5].find('span').get_text().strip()
        # channel = columns[7].find('span').get_text().strip()

        print(link, quality, language)
else:
    print('No streams found')
