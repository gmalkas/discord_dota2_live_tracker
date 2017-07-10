# Dota2 Live Tracker Discord Bot

The Dota2 Live Tracker Discord Bot allows Discord users to receive live updates
from [ongoing competitive Dota2 games](http://www.trackdota.com/).

## Installation

To add this Bot to your Guild/Server, use the following link:
https://discordapp.com/oauth2/authorize?client_id=331909791024939008&scope=bot&permissions=26688

## Available Commands

    **d2l:list**
        lists currently live games

    **d2l:sub:$game_id**
        subscribe to the given game

    **d2l:unsub:$game_id**
        unsubscribe from the given game

    **d2l:help**
        prints this help message

## Running locally
If you want to run a version of the bot on your own server, you will need to
install Erlang 20.0 and Elixir 1.4.5 then create a Discord application with a
Bot user to receive a client ID and Bot Token. You will also need a Steam
API Key.

You can then run the bot server:
```bash
$ cd /path/to/bot
/path/to/bot$ mix deps.get
/path/to/bot$ DISCORD_BOT_TOKEN="Bot YOUR_TOKEN" STEAM_API_KEY="KEY" iex -S mix
```
