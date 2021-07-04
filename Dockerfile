FROM ubuntu:20.04

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2

RUN apt-get update && apt-get install -y apache2

RUN mkdir /var/run/apache2

ADD cgi-bin/shockme.cgi /usr/lib/cgi-bin/
RUN chmod +x /usr/lib/cgi-bin/shockme.cgi

RUN a2enmod cgid

# Install vulnerable bash
RUN apt-get install -y build-essential wget

# DO NOT Install vulnerable bash 4.3 from package
# RUN wget https://snapshot.debian.org/archive/debian/20140304T040604Z/pool/main/b/bash/bash_4.1-3_amd64.deb
# RUN dpkg -i bash_4.1-3_amd64.deb

# Or build bash 4.3 from source
# RUN wget https://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz && \
#     tar zxvf bash-4.3.tar.gz && \
#     cd bash-4.3 && \
#     ./configure && \
#     make && \
#     make install

# Make HTML directory writeable - it's cheating, but it makes the exploit really easy to demo
# RUN chmod o+w /var/www/html

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2"]

CMD ["-D", "FOREGROUND"]
