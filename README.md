# the_last_bluetooth

This is my own internal library for FreeBuddy app. Things may seem biased, and may change chaotically in future

However, I owe myself rights to pretend like it's seriously planned for future and all design decisions are thought-through

Cheers!

# Organization of this library:

## Flutter/Stream-like organization
Everything is done as much "Flutter-way" as possible, while heavily using Futures/Streams

Every value that can anyhow change in future is a Stream - more precisely, a `ValueStream` from `rxdart` library

I know that bringing yet another dependency may seem messy - however, `rxdart` is just based as fuck

![Gigachad](https://web.archive.org/web/20230825195048if_/https://i.imgur.com/EW1wCI4.png)

### Everything is a stream*
*almost

Yes. Because even availability of bluetooth may change (you can plug a usb card in and out 👀)

And #1 thing I hate when UI apps don't react to what's happening, and you need to refresh/reopen stuff

## As few boilerplates/reduntant helpers as possible

Example: 