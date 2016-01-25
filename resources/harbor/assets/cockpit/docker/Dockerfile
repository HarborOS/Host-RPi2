FROM armv7/armhf-fedora:23
LABEL License="Apache 2.0" \
      Vendor="Harbor OpenStack"
MAINTAINER Pete Birley <petebirley@gmail.com>

ENV container docker


RUN dnf update -y && \
    dnf install -y cockpit-ws \
    dnf clean all

# And the stuff that starts the container
RUN mkdir -p /container && ln -s /host/proc/1 /container/target-namespace
ADD init /container/init
ADD install.sh /container/install.sh
RUN chmod -v +x /container/init /container/install.sh

# Make the container think it's the host OS version
RUN rm -f /etc/os-release /usr/lib/os-release && ln -sv /host/etc/os-release /etc/os-release && ln -sv /host/usr/lib/os-release /usr/lib/os-release


CMD ["/container/init", "--local-ssh"]
