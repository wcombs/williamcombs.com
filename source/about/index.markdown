---
layout: about
title: "What's going on here?"
comments: false
sharing: false
footer: false
sidebar: false
---
This site is my attempt at sharing something back to the collective conscience that is the internet. I've had sites in the past but left them for dead for various reasons. My first was a classic Geocities page with crazy gifs and under contruction logos all over. My second was a simple blog about tech projects I was working on at the time. Life got crazy and I left those sites behind, but now I'm finding I have more stuff to share, so it's time to start it back up. I've shyed away from blogging up to this point because of a dilemma I have with the inherent vanity of the activity. I've come to realize that if I reach one person, and teach them something unique, then it's all worth it, so that will be my goal (and I'll try to contain all the self-important rantings on this page). 

The tools available these days to get a site up and running are numerous and amazing. I messed with WordPress (which has come a long way) and eventually landed on OctoPress as my CMS. I run a micro EC2 instance in AWS' East Coast availability zone, with CentOS as my current server distro of choice. OctoPress is a framework that makes it easier to take advantage the blog-aware, static site generator in Ruby, Jekyll. What this means is that my site is a series of easily customizable templates (using the Liquid templating library), styled by easily customizable Sass CSS3 stylesheets, and my content is just in plain old text files and is written in the highly human-readable markdown syntax, using my editor of choice, vim of course. What this also means is that my site is re-generated in its entirety every time I make and publish a change, and it is fully static, requiring no db, and no server-side processing (php ala wordpress, etc..). I run a Linux server with apache to host these static pages but really that is overkill, as I could throw my site up on a CDN like S3, or even host it from GitHub or Heroku, but I enjoy the activity of maintaining a remote linux box, so I'll stick with my current setup for now.
