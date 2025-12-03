# FROM <image>[:<tag>|@<digest]
FROM ubuntu:24.04
LABEL maintainer="Anthony Kiehl"
LABEL email="anthony.kiehl@siemens.com"

#setup environment
ENV TIMEZONE=America/Los_Angeles 
EXPOSE 8945/tcp 8946/tcp 8022/tcp 61616/tcp 61617/tcp
SHELL ["/bin/sh", "-c"]

#install tools
RUN apt-get update -y \
	&& apt-get install vim net-tools tuned wget unzip expect software-properties-common supervisor curl xvfb rsync -y

#download latest install script
RUN wget "https://storage.googleapis.com/csi-cdi-anzo/release-ga/releases/6.1.0/r202507021236/altair_graph_studio_server_linux_amd64_6_1_0_r202507021236.sh" -O anzo_script.sh \
	&& chmod +rx anzo_script.sh

#inject files
COPY . ./ 

#run installer 
RUN /script.exp

#cleanup
RUN apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/ \
        && rm -rf /anzo_script.sh

#launcher
VOLUME ["/opt"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]
