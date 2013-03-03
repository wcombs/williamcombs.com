---
layout: about
title: "What's going on here?"
comments: false
sharing: false
footer: false
sidebar: false
---
*My name is Will Combs and I like to make stuff.*

I’ll define *stuff* in the scope of this site as any project that involves solving problems through the synthesis of readily available components and technologies. Basically, I’m a Linux Sysadmin by day (well, by night too), and I like to work with electronics and programming in my spare time, with the ultimate goal of making cool stuff.

I’ve found that forums, blogs, and other online communities inspire and guide many of my projects. When you are stumped on a project there is nothing more helpful than finding a detailed write-up by another hobbyist who tackled a similar challenge, and this site is my attempt at providing more write-ups like this, with the ultimate goal of sharing something back to the collective conscience that is the internet.

I've had sites in the past but left them for dead for various reasons. My first was a classic Geocities page with crazy gifs and under contruction logos all over. My second was a simple blog about tech projects I was working on at the time. Life got crazy and I left those sites behind, but now I'm finding I have more stuff to share, so it's time to start it back up. I've shyed away from blogging up to this point because of a dilemma I have with the inherent vanity of the activity. I've come to realize that if I reach one person and teach them something unique, then it's all worth it. So that will be my goal, and I'll try to contain all the self-important rantings on this page. 

__The Backend__

This is where I'll blog about blogging. The tools available these days to get a site up and running are numerous and amazing. I messed with WordPress (which has come a long way) and a few other blogging platforms, and eventually landed on OctoPress as my CMS. OctoPress is a framework that makes it easier to take advantage the blog-aware static site generator, Jekyll. What this means is that my site is a series of templates (using the Liquid templating library), styled by Sass CSS3 stylesheets, and my content is just in plain old text files and is written in the human-readable markdown syntax, using the best text editor ever made (vim of course). What this also means is that my site is re-generated in its entirety every time I make and publish a change, and it is fully static, requiring no db, and no server-side processing (php/mysql ala wordpress, etc.). Since my site is static, I host it from Amazon S3, using Cloudfront for a speedier geo-optimized delivery. I've modified the main Octopress branch in many ways to make all of this possible, and to customize the look and feel of this site, and you can see my tweaks [here](https://github.com/wcombs/williamcombs.com).

I'll update this section periodically, so check back. Now for the obligatory social media links (don't worry, only two).

Check out my code on [Github](https://github.com/wcombs).

Message me on [Twitter](https://twitter.com/combsw).

<br />
<p style="color:rgb(130,130,130)"><em>Last updated Jul 27, 2012</em></p>
