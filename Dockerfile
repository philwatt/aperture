# create a new container for Aperture Data Studio 

# FROM a baseline centos

FROM centos:7
ENV container=docker
# set up systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#ENV container=docker
# make the Aperture install available locally
ADD ./rpms/ApertureDataStudio-1.3.1-1.el7.x86_64.rpm ./rpms/
# make the JDK install available locally
ADD ./rpms/jdk-8u201-linux-x64.rpm ./rpms/
# install and run web server services. install sudo so that we can run systemctl without executing in privileged mode
RUN yum -y install sudo && yum clean all
# install Oracle version of JDK
RUN yum localinstall -y ./rpms/jdk-8u201-linux-x64.rpm
# install Aperture Data Studio
RUN yum localinstall -y ./rpms/ApertureDataStudio-1.3.1-1.el7.x86_64.rpm

# make the services known to the system - systemd hard to manage through dockerfiles - seeking alternative as these systemctl files don't work!
#RUN  systemctl daemon-reload

# create the symlinks
RUN systemctl enable ApertureDataStudio_1.3.1

# start the service
#RUN systemctl start ApertureDataStudio_1.3.1

# Check the service status
#RUN systemctl status –l ApertureDataStudio_1.3.1

# expose ports for Aperture
EXPOSE 80
EXPOSE 7701
EXPOSE 7801
EXPOSE 22
EXPOSE 443
# define the mount points to persist beyond the container life
VOLUME ["/home/experian", "/var/www/html", "/sys/fs/cgroup" ]

ENTRYPOINT [ "systemctl", "start", "ApertureDataStudio_1.3.1" ]

CMD ["/usr/sbin/init"]
