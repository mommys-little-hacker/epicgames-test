# DevOps Engineer Test, Epic Games Helsinki

FINAL as of March 19th, 2019

## Introduction
We use this test to avoid whiteboard coding in the interview and to have a base level
understanding of technical competency of candidates.

## Question 1
Write a script in bash, ruby, python or golang that in parallel would collect per process used
memory across 50 linux hosts. The collected information should be output to a suitable metrics
back-end via statsd(TICK, prometheus, statsite) If you are not sure what this is, then please
use https://github.com/obfuscurity/synthesize. Please do not use an agent such as telegraf or
collectd. We would like to see how you would code this :)

### Answer
See [source/q1/poller.sh](source/q1/poller.sh)
This script needs a file containing list of SSH usars and hosts in this format:
```
user0@host0.example.com
user1@host1.example.com
```
Place it in the same directory and name it `hosts.txt`, then run `./poller.sh`
in this directory.

## Question 2
Given the same scenario in question 1, what would you change or consider if you needed to run
this across 10,000 hosts across multiple regions? Please describe this in detail including how
you would architect and scale metrics collection and services.

## Question 3
Given the same scenario from question 2, how do you know the statsd service is working
correctly? What monitoring or metrics would you put in place if this was a production service?
Please talk about specific architectures and systems you would use for this monitoring tool.
Gotchas are an a+.

## Question 4
If 1% of hosts(out of 10k total) were kernel OOMing every hour(with linux OOMkiller kicking in),
what action would you take to auto remediate? How would you discover and monitor that the
hosts were in fact running out of memory?
