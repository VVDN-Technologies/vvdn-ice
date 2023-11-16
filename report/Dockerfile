FROM alpine:latest

COPY pricing-reporting /usr/local/bin/

RUN echo "* * * * * /usr/local/bin/pricing-reporting" > /etc/crontabs/root

CMD ["/usr/sbin/crond", "-f", "-d", "0"]