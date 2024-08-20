
# cdl-docker

To automatically build + push every hour, add the following to your crontab -e

    0 * * * * cd /root/cdl-docker && ./build_docker.sh >> /root/cdl-docker/build_log.txt 2>&1

