Apr 18, [2021](/blog/2021/)

# I have been tricked!

I have always thought of myself as a rather careful person when doing stuff on the internet. But today, I noticed how I've been tricked on Telegram platform.

[I have written a Telegram bot](/blog/2021/fnbot/), and because I host the project publicly on GitHub, sometimes mistakes happen. One of those mistakes including leaving my full API key in the code before pushing it to the repository.

Everytime such mistake happens, I usually noticed within a few minutes, and I always removed the entire repository and start anew.

Within that very small time frame, it seems some malicious actors have successfully get a look at my API key, and use the key to authenticate as my bot, and _tricked_ me to authenticating his login to my Telegram account.

## How I was tricked

When debugging my bot, the bot some how sent me a seemingly from-Telegram message with something like "we need to check if you are the real person, so please gimme the code we just sent in the SMS".

It turned out that message was not from Telegram, but from a bot which used my API token. I believed he wanted the authentication code to get access to my Telegram account.

But luckily enough, Telegram promptly alerted me, but because I was dumb, I didn't see that message promptly - instead it took me >2 hours to notice the alert message.

After I saw the message, I terminated all sessions, setup 2F authentication, and delete the old bot.

This is my first kinda 'hacked' lesson for me, and I will always remember it. Thank God I don't have any chats on Telegram.

My other internet accounts should not be compromised, since all of my passwords are randomly generated, and I don't link internet accounts with "Sign In with _blah blah blah_".
