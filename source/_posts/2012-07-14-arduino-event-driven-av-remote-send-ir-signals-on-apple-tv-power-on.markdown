---
layout: post
title: "Arduino Event-Driven Universal AV Remote"
subtitle: "This is the subtitle."
date: 2012-07-14 11:53
comments: true
published: false
sidebar: false
categories: tech
---
*Turn Everything on with Airplay*
<!-- more -->
__tl;dr__ - I wanted all of my AV components to turn on and change inputs as soon as I started airplaying music to my AppleTV from my iPhone, so I popped open the AppleTV, wired up a photocell sensor to an Arduino Uno, wired up some Infrared LEDs, wrote some code, and made it happen. Here it is in action.

<iframe src="http://player.vimeo.com/video/40527165" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe><p><a href="http://vimeo.com/40527165">Shuttle Pass 1 Georgetown</a> from <a href="http://vimeo.com/user10143591">Will Combs</a> on <a href="http://vimeo.com">Vimeo</a>.</p>

__Problem Details__

When I want to listen to music on my AV system, I hit airplay on my idevice (in itunes/pandora/spotify) and my apple tv turns on and starts playing, but the other components do not. I have to fumble through a thousand remotes for the tv remote to power it on and change the hdmi source, then for the AV receiver remote for power and source and speaker select. The elegance of airplay is lost at this point. I know your thinking what's the big deal, first world problems etc... But this is a simple problem, and should have a simple standard solution. I came up with a solution, but it was by no means simple.

__My Solution__

First, I found what I thought was my solution, HDMI CEC. This standard in theory lets you control all devices from one remote, and makes devices like the TV listen for activity on the HDMI ports and power on and change sources automatically. The idea was perfect, but unfortunately at this point the implementation of this standard seems fragmented, with each manufacturer having their own proprietary version. My LG TV had its own version but none of my other components worked with that version. Also, from what I've found, no version of the AppleTV supports this yet.

After some reading on forums, I found people who had success with AppleTV and one of these, so I ordered one. I wired all of my HDMI devices into it but had no luck with auto-power on or auto-input select, so I quickly returned it.

At this point, I looked at my Ardunio UNO board, and figured this would be a perfect job for the little microcontroller with a bunch of inputs (to listen for AppleTV power-on) and outputs (to send IR signals). Some quick googling confirmed my suspicion; tons of people are sending IR signals with their Arduinos. These write-ups were particularly helpful:

So, sending IR signals has been covered in detail, and there's more on my specific implementation below, but sensing when the AppleTV powers on was still a problem, a fun problem to solve.

__Sensing AppleTV Power-on__

AppleTV always in standby state if plugged in, but could theoretically check current draw and look for a threshold, assuming it uses more power when it actually is in use. Could maybe sense network traffic, but that is always on as well, using bonjour so it shows up on other idevices on the network. Then I thought about the power led, could tie into the wire that powers that led and sense current, then trigger power on. Not a good practice to physically connect to another circuit. Finally, thought of using a light sensor, a simple photocell, but the issue of ambient light made me wonder if it would work.  Turns out, if its inside the plastic enclosure, hardly any ambient light gets in, and it reliably senses the led no matter what the light conditions outside the case are.

__Sending IR Signals__

show adafruit ir listener and sending code, to get already known codes
Adafruit code enabled me to listen and recreate commands from remotes I have, but there is an issue with the tv remote, having only one power button, that turns it on if off and off if on.  Since I am not tracking the power state of the TV I needed a way to just send 'on' without turning off if already on, this is where discrete codes again.

explain discrete codes and show pronto database, and pronto converter script

show sending parts of code, just the functions for the different types of sending

__Building the Circuit__

breadboard, then protoshield

link to circuit on circlab

__Writing the Code__

link to helping code

link to github for my code, bringing sending, listening code in together

__Final Product, and Other Ideas__

show some pics, vids of it in action

other ideas: more input events, wifi/eth connected for remote controllability, do away with all remotes eventually
