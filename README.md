# auto-speedtest
Simple speedtest-cli result aggregation

The goal of this project is to provide simple automated speedtest tracking and display.

Supported Platforms
-------------------
The tool was developed and tested on Ubuntu 14.04 using Apache2 as the webserver. YMMV on other platforms.

Requirements
------------
This project requires the excellent [speedtest-cli](https://github.com/sivel/speedtest-cli) tool to be installed and accessible at `/usr/bin/speedtest-cli`

Installation
------------

Someday this should be automated. In general:

1. Setup a cron rule to execute `run-speedtest.sh` periodically. I use once every 20 minutes. For example, my crontab entries are:

  ```
*/20 * 1-31/2 * * /home/awm129/src/auto-speedtest/run-speedtest.sh
10-50/20 * 2-30/2 * * /home/awm129/src/auto-speedtest/run-speedtest.sh
  ```
2. Ensure the `/srv/speedtest/` directory exists and it accessible to cron and your webserver
3. Configure your webserver to serve the following files:
  * index.html
  * speedtest.png
  * speedtest.js
  * speedtest.csv (generated by run-speedtest.sh)
