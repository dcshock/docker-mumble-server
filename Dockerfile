FROM ubuntu:latest
MAINTAINER Matt Conroy matt@conroy.cc

# Upgrade the build and include the universe repo.
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install the mumble dependencies
RUN apt-get install -y libicu48 libterm-readline-perl-perl
RUN apt-get install -y openssh-server mumble-server
RUN mkdir -p /var/run/sshd

# Install supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
RUN locale-gen en_US en_US.UTF-8
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Hack for initctl
# See: https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# Make the ports available for SSH and Mumble.
EXPOSE 22
EXPOSE 64738

# Server startup command
CMD ["/usr/bin/supervisord"]

# Set the initial superuser password to admin
RUN /usr/sbin/murmurd -fg -ini /etc/mumble-server.ini -supw admin
