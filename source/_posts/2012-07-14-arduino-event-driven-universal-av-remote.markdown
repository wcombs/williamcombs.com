---
layout: post
title: "Arduino Event-Driven Universal AV Remote"
date: 2012-07-14 11:53
comments: true
published: false
sidebar: false
categories: tech
---
*Turn Everything on with Airplay*
<!-- more -->
__TL;DR__ - I wanted all of my AV components to turn on and change inputs as soon as I started Airplaying music to my Apple TV from my iPhone, so I popped open the Apple TV, wired up a photocell sensor to an Arduino Uno, wired up some Infrared LEDs, wrote some code, and made it happen. Here it is in action.

<iframe src="http://player.vimeo.com/video/58252927" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

__The Problem__

When I want to listen to music on my AV system, I hit Airplay on my iDevice (in itunes/pandora/spotify) and my Apple TV turns on and starts playing, but the other components do not. I have to fumble through a thousand remotes for the tv remote to power it on and change the HDMI source, then for the AV receiver remote for power and source and speaker select. The elegance of Airplay is lost at this point.

__Finding a Solution__

First, I found what I thought was my solution, HDMI CEC. This standard (in theory) lets you control all devices from one remote, and makes devices like the TV listen for activity on the HDMI ports and power on and change sources automatically. The idea was perfect, but unfortunately at this point the implementation of this standard seems fragmented, with each manufacturer having their own proprietary version. My LG TV had its own version but none of my other components worked with that version. Also, from what I've found, no version of the Apple TV supports this yet.

After some reading on forums, I found people who had success with Apple TV and [one of these](http://www.monoprice.com/products/product.asp?c_id=101&cp_id=10110&cs_id=1011002&p_id=6259&seq=1&format=2), so I tried it. I wired all of my HDMI devices into it but had no luck with auto-power on or auto-input select, so it was back to the drawing board.

At this point, I looked at my Ardunio UNO board, and figured this would be a perfect job for the little microcontroller with a bunch of inputs (to listen for Apple TV power-on) and outputs (to send IR signals). Some quick googling confirmed my suspicion; lots of people are sending IR signals with their Arduinos.

So, sending IR signals has been covered in detail, and there's more on my specific implementation below, but sensing when the Apple TV powers on was still a problem to be solved.

__Sensing Apple TV Power-on__

The Apple TV is always in a standby state if plugged in, which gives it the ability to advertise itself on the local lan, and turn on when a device Airplays to it. To sense its state you could theoretically check current draw and look for a threshold, assuming it uses more power when it actually is in use, and not in standby. I didn't go into detail vetting this solution, but may investigate it more. Another way might be to sense network traffic, there may be a specific packet that is transmitted when the unit comes out of standby, but my current Arduino setup was to be standalone and not connected to my lan, so this would have to wait for another version.

Then I thought about the power led, couldn't I tie into the wire that powers that led and sense voltage? This solution would involve physically connecting two circuits, which isn't really best practice. I still liked the idea of using the power LED so I came up with using a light sensor, a simple photocell, but the issue of ambient light made me wonder if it would be able to tell the difference reliably. After installing the photocell into the Apple TV unit it turns out hardly any ambient light gets in, and it reliably senses the led no matter what the light conditions outside the case are. It's not as simple as just sensing on or off, since the light turns off when buttons on the remote are pressed, so I had to code a threshold to keep the system from triggering on and off events erroneously.

{% codeblock Power LED Sensing Code lang:c http://github.com/wcombs check it out on github %}
const int photocellPin = 0;
int photocellReading;     
int appletvState = 0;
int mightBeOn = 0;
int mightBeOff = 0;

// set these to customize sensitivity
const int appletvOnThresh = 200;
const int appletvOffThresh = 10;
const int numOnThreshChecksNeeded = 1000;
const int numOffThreshChecksNeeded = 5000;

...

void loop() {
    photocellReading = analogRead(photocellPin);

    ...

    if (appletvState == 0) {
        if (photocellReading > appletvOnThresh) {
            mightBeOn++;
        } else if (mightBeOn > 0) {
            mightBeOn--;
        }
        if (mightBeOn == numOnThreshChecksNeeded) {
            mightBeOn = 0;
            appletvState = 1;
            sendAppleTVAllOnSequence();
        }
    }
    
    if (appletvState == 1) {
        if (photocellReading < appletvOffThresh) {
            mightBeOff++;
        } else if (mightBeOff > 0) {
            mightBeOff--;
        }
        if (mightBeOff == numOffThreshChecksNeeded) {
            mightBeOff = 0;
            appletvState = 0;
            sendAppleTVAllOffSequence();
        }
    }
}
{% endcodeblock %}

So at this point I can reliably sense the state of the Apple TV and fire any action I need to. Now I just needed to give the Arduino some IR capabilities.  Easy right?

__Infrared Signaling__

All AV equipment, new and old, tends to have an IR sensor, and every IR remote has an IR LED to shoot out pulsed IR light. Remotes are programmed to pulse that IR LED at a very high rate (roughly 38KHz is the standard for most remotes, or 38000 pulses a second). This pulsing is called modulation, and the sensor on the receiver device has to demodulate that signal to decode it and take action, depending on what code was received. Beyond this 38KHz pulsing, IR signals are made up of on/off sequences just like any other binary transmission, but this pulsing happens in the millisecond range. The modulation keeps stray IR light from affecting specific signals coming from IR transmitters.

I wanted to reproduce certain remote control functions such as 'on' and 'input change' but first I had to deconstruct and record these patterns.  I used two methods, capturing the signal from existing remotes, and translating the signal from an online database of remote codes.

__Capturing IR Signals from Existing Remotes__

The best tutorial for using an Arduino to send and receive IR signals (by far) is [this one](http://learn.adafruit.com/ir-sensor/overview) by Adafruit. They explain modulation/demodulation and provide code to get your Arduino sending and receiving IR in no time. To 'record' codes from my current remots I used this [code from github](https://github.com/adafruit/Raw-IR-decoder-for-Arduino), with my Uno wired up to an IR sensor like this.


[![alt text][img1]][img1]
[img1]: /images/arduinopna4602.gif
*Image Source: Adafruit Learning System (http://learn.adafruit.com/assets/555)*

When you load that code onto your Arduino, open the serial console, point any remote control at it, and press a button, it prints out the pulse/delay sequence you'll need to reproduce it. Using this method, here is my (shortened) function to send the "power on" signal for my Harman Kardon receiver.

{% codeblock HK Power On Function lang:c %}
void sendHKDiscreteOn() {
    pulseIR(8820);
    delayMicroseconds(4460);
    pulseIR(520);
    delayMicroseconds(560);
    ... 
    pulseIR(8820);
    delayMicroseconds(2200);
    pulseIR(520);
    delayMicroseconds(28724);
    pulseIR(8840);
    delayMicroseconds(2200);
}
{% endcodeblock %}

You can see from the function above that IR codes are just a series of timed pulses and delays. I used this method to record the "On", "Off", and "Input Select Vid 1" codes from my HK remote. 

__Translating IR Codes from Pronto Hex Format__

Since the Apple TV connects to my LG TV I needed to be able to power the TV on and change input, just like the HK Receiver. I planned to use the same method as above, but then realized my LG Remote doesn't have a specific "On" button, just a power button, and only has one button to cycle through all Inputs. Since I have no reliable way to sense the state of the TV, and which input was currently selected, these 2 remote buttons wouldn't work for my solution. So I went googling, and learned about "discrete IR codes". These codes perform one specific function, such as "Power On" and "Select Input Source 1". The codes are understood by the IR receiver firmware on the TV, but are just not included on the stock TV remote. Luckily, I found a site where people post these discrete codes in a standard format. [Here](http://www.remotecentral.com/cgi-bin/mboard/rc-prontong/thread.cgi?6013,2) are the discrete power and input select codes for my TV (and I believe most other LG TVs). The format is known as "Pronto Hex" and [this article](http://www.hifi-remote.com/infrared/IR-PWM.shtml) explains how to decode it.

I wrote a ruby script based on the conversion instructions in that article, to convert Pronto Hex format to a set of pulse/delay sets that I could plug into my Arduino program. You can get the [code on github here](https://github.com/wcombs/combs_pronto_hex_ir_to_arduino).

__Sending IR Signals with Arduino__

So at this point I have all the codes I need, but I need a way to send them at my devices. The hardware involved is just a simple IR LED (actually a set of them wired in parallel and placed in front of each shelf of AV equipment, will cover this in the next section). The software comes from the Adafruit tutorial. To send the recorded signal I used Adafruit's IR sending function, which pulses on and off at 38KHz for a number of microseconds. This function is the backbone my project and I want to give full attribution and thanks to Adafruit for doing the dirty work. The code is on [github here](https://github.com/adafruit/Nikon-Intervalometer), and here is the function.

{% codeblock Adafruit pulseIR function lang:c %}
// This procedure sends a 38KHz pulse to the IRledPin 
// for a certain # of microseconds. We'll use this whenever we need to send codes
void pulseIR(long microsecs) {
  // we'll count down from the number of microseconds we are told to wait
  
  cli();  // this turns off any background interrupts
  
  while (microsecs > 0) {
    // 38 kHz is about 13 microseconds high and 13 microseconds low
   digitalWrite(IRledPin, HIGH);  // this takes about 3 microseconds to happen
   delayMicroseconds(10);         // hang out for 10 microseconds
   digitalWrite(IRledPin, LOW);   // this also takes about 3 microseconds
   delayMicroseconds(10);         // hang out for 10 microseconds

   // so 26 microseconds altogether
   microsecs -= 26;
  }
  
  sei();  // this turns them back on
}
{% endcodeblock %}

As of now I use two different formats for IR signals in my Arduino code, the first being a function like sendHKDiscreteOn() above, and the second being a more compressed format from my Pronto Hex conversion script. Here is the LG TV Discrete On code in that format.

{% codeblock Compressed Pronto Hex Converted Format lang:c %}
const int lgTvDiscreteOn[17*3] = {1, 8918, 4472,
                                  2, 546, 572,
                                  1, 546, 1690,
                                  5, 546, 572,
                                  2, 546, 1690,
                                  1, 546, 572,
                                  5, 546, 1690,
                                  2, 546, 572,
                                  1, 546, 1690,
                                  3, 546, 572,
                                  4, 546, 1690,
                                  1, 546, 572,
                                  3, 546, 1690,
                                  2, 546, 572,
                                  1, 546, 39260,
                                  1, 8820, 2200,
                                  1, 546, 28620};
{% endcodeblock %}

Codes in this format are stored in array constants and I wrote this function to send the code. 

{% codeblock My sendIRSignal Function lang:c %}
void sendIRSignal(int *arr, int size) {
    int i, j;
    digitalWrite(statusLedPin, HIGH);
    for(i = 0; i < size/3; i++) {
        for(j = 0; j < arr[i*3]; j++) {
            pulseIR(arr[(i*3)+1]);
            delayMicroseconds(arr[(i*3)+2]);
        }
    }
    digitalWrite(statusLedPin, LOW);
}
...
example usage:
sendIRSignal(lgTvDiscreteOn, sizeof(lgTvDiscreteOn)/sizeof(int));
{% endcodeblock %}

Finally, after a bunch of testing and tweaking, I came up with functions to replay all the codes to control my AV receiver and TV. Here is the one that powers everything on.

{% codeblock My sendIRSignal Function lang:c %}
void sendAppleTVAllOnSequence() {
    for(int i = 0; i < num_resends; i++) {
        sendIRSignal(lgTvDiscreteOn, sizeof(lgTvDiscreteOn)/sizeof(int));
        delay(100);
        sendIRSignal(lgTvDiscreteHDMI2, sizeof(lgTvDiscreteHDMI2)/sizeof(int));
        delay(100);
        sendHKDiscreteOn();
        delay(100);
        sendHKDiscreteVid1();
        delay(500);
    }
    // wait for tv to turn on if it was off 
    delay(10000);
    for(int i = 0; i < num_resends; i++) {
        sendIRSignal(lgTvDiscreteOn, sizeof(lgTvDiscreteOn)/sizeof(int));
        delay(100);
        sendIRSignal(lgTvDiscreteHDMI2, sizeof(lgTvDiscreteHDMI2)/sizeof(int));
        delay(100);
        sendHKDiscreteOn();
        delay(100);
        sendHKDiscreteVid1();
        delay(500);
    }
}
{% endcodeblock %}

Each sequence is sent a few times for some added reliability, and the 10 second delay in the middle is for when the TV is off, as it takes a few seconds to turn on.

I also added a function to set the HDMI select back to the DirecTV box and power everything down. This one will be used when the Apple TV powers off.

{% codeblock My sendIRSignal Function lang:c %}
void sendAppleTVAllOffSequence() {
    if (debugMode) {
        Serial.print("Sending Apple TV All Off Sequence...");
    }
    for(int i = 0; i < num_resends; i++) {
        sendIRSignal(lgTvDiscreteHDMI1, sizeof(lgTvDiscreteHDMI1)/sizeof(int));
        delay(100);
    }
    if (debugMode) {
        Serial.println("Done");
    }
} 
{% endcodeblock %}

Now I have all the software components, time to bring it all together.

__Coding it Up__

Here's my pseudocode for the sketch that gets loaded onto my Uno, and a link to the actual code.

{% codeblock Arduino IR Controller Pseudocode lang:c %}
set appletvState to 0
set mightBeOn to 0
set mightBeOff to 0
set photocellReading to 0
set appletvOnThresh to 200
set appletvOffThresh to 10
set numOnThreshChecksNeeded to 1000
set numOffThreshChecksNeeded to 5000
set blackButtonState to 0
set redButtonState to 0

Main Run Loop (while true):
    get photocellReading
    get redButtonState
    get blackButtonState

    if appletvState is 0:
        if photocellReading is greater than appletvOnThresh:
            increment mightBeOn by 1
        else if mightBeOn is greater than 0:
            decrement mightBeOn by 1
        
        if mightBeOn equals numOnThreshChecksNeeded:
            set mightBeOn to 0
            set appletvState to 1
            send IR signals to turn on TV, Receiver, and change to correct inputs
            wait for TV to fully turn on, then send again to make sure input changes if TV was off 

    if appletvState is 1:
        if photocellReading is less than appletvOffThresh:
            increment mightBeOff by 1
        else if mightBeOff is greater than 0:
            decrement mightBeOff by 1

        if mightBeOff equals numOffThreshChecksNeeded:
            set mightBeOff to 0
            set appletvState to 0
            send IR signals to turn TV back to DirecTV input and turn stuff off

    if blackButtonState is pressed:
        send IR signals to turn on TV, Receiver, and change to correct inputs
        wait for TV to fully turn on, then send again to make sure input changes if TV was off 
    else if redButtonState is pressed:
        send IR signals to turn TV back to DirecTV input and turn stuff off
            
{% endcodeblock %}

Now that I have all the code needed to make this work, it's hardware time.

__Building the Circuit__

To prove that this all worked, I started with my solderless breadboard and wired up the circuit like I wanted it. This is the best way to experiment with the Arduino and learn how the analog and digital inputs and outputs work, since you can just mix and match leads and see what happens.

pic of breadboarding
[![alt text][img2]][img2]
[img2]: /images/2012-05-03-20.05.55.jpg
*This is where you should put captions*

Then I found this great online circuit schematic editor/simulator circuitlab.com.  I drew up my circuit to have a reference, with the Arduino simplified to the inputs/outputs actually used.

link to circuit on circlab
[![alt text][img3]][img3]
[img3]: /images/circuitV1.png
*This is where you should put captions*

The Arduino was built to be the core of a project, to which you can add and extend functionality, using the idea of 'shields' which basically connect and extend the inputs and outputs of the main board.  The best way I found to make a more permanent version of my breadboarded mess of wires, was the 'protoshield' from adafruit. This board gives you an open grid of conductor-lined holes to solder to, and plugs right into the arduino uno without any modification to the uno.

protoshield pics (link to adafruit store item)
[![alt text][img4]][img4]
[img4]: /images/protoshield_LRG.jpg
*This is where you should put captions*

__Getting my Solder On__

I used black XX guage solid copper wire for the leads, and rosin core XX/XX solder with my variable temp soldering iron.  This clamp kit helped keep things in place while I soldered.

soldering it together pics
[![alt text][img5]][img5]
[img5]: /images/2012-05-07-17.50.00.jpg
*This is where you should put captions*

[![alt text][img20]][img20]
[img20]: /images/2012-12-24-15.37.19.jpg
*This is where you should put captions*

[![alt text][img21]][img21]
[img21]: /images/2012-12-24-15.37.44.jpg
*This is where you should put captions*


PIC needed showing underside of finished protoshield


finished protoshield pics
caption: Once the protoshield was all soldered up, it's ready to plug onto the uno

__Getting Photocell Sensor into my Apple TV__

First, I popped it open, using a butterknife and carefully prying the edges on the bottom until the top popped off.

[![alt text][img6]][img6]
[img6]: /images/2012-05-07-17.38.49.jpg
*This is where you should put captions*

[![alt text][img7]][img7]
[img7]: /images/2012-05-07-18.07.56.jpg
*This is where you should put captions*


[![alt text][img8]][img8]
[img8]: /images/2012-05-07-18.36.38.jpg
*This is where you should put captions*


[![alt text][img9]][img9]
[img9]: /images/2012-05-07-18.45.24.jpg
*This is where you should put captions*

__Installation__

To make sure IR signals made it everywhere, I ran 3 IR LEDs in parallel, connected back to the board by the same solid core copper wire that I used on my shield.  One LED sits right in front of the TV, and the Other two sit on each level of my AV cabinet. There are also two leads from the Apple TV that I ran back to the shielded uno.

[![alt text][img10]][img10]
[img10]: /images/2013-01-26-12.30.09.jpg
*This is where you should put captions*

[![alt text][img11]][img11]
[img11]: /images/2013-01-26-12.45.26.jpg
*This is where you should put captions*

I added an rj45 connector so I could use a cat5 run for a box with buttons. The buttons let me do a manual all-on or all-off if I need to.

[![alt text][img22]][img22]
[img22]: /images/2012-12-28-14.49.21.jpg
*This is where you should put captions*

pics of button box and plug in
[![alt text][img12]][img12]
[img12]: /images/2013-01-26-12.47.11.jpg
*This is where you should put captions*

__Final Product, and Other Ideas__

The project has been running solid for weeks now with no problems, even though it still looks a little prototypy.

show some pics, vids of it in action

other ideas: more input events, wifi/eth connected for remote controllability, do away with all remotes eventually
