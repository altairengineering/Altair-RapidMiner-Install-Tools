# FROM <image>[:<tag>|@<digest]
#FROM ubuntu:24.04
FROM robertglonek/ubuntu:24.04
LABEL maintainer="Anthony Kiehl"
LABEL email="anthony.kiehl@siemens.com"

#setup environment
ENV TIMEZONE=America/Los_Angeles 
EXPOSE 8080/tcp 8443/tcp 8945/tcp 8946/tcp 8022/tcp 61616/tcp 61617/tcp
SHELL ["/bin/sh", "-c"]

#install tools
RUN apt-get update -y \
	&& apt-get install vim net-tools tuned wget unzip expect software-properties-common curl xvfb rsync -y
	#&& apt-get install vim net-tools tuned wget unzip expect software-properties-common supervisor curl xvfb rsync -y

#download latest install script
#RUN wget "https://storage.googleapis.com/csi-cdi-anzo/release-ga/hotfix/6.2.1/r202511141311/altair_graph_studio_server_linux_amd64_6_2_1_r202511141311.sh" -O anzo_script.sh 
RUN wget "https://cso-cloud-storage.s3.us-west-1.amazonaws.com/anzo_studio/graph_studio_server_linux_amd64_6_3_0_r202605051012.zip" -O graph_server.zip
RUN unzip -bb -P oV6W6teY2Dmn0p5lJZNo graph_server.zip

#inject files
COPY . ./ 

RUN chmod +rx anzo_script.sh
RUN chmod +rx script.exp
#RUN chmod +rx entrypoint.sh
#RUN mkdir -p /opt/Anzo
#run installer 
RUN /script.exp

RUN echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN mkdir -p /etc/apt/keyrings
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc 
RUN apt-get update -y \
        && apt-get install temurin-21-jdk -y


#cleanup
RUN apt-get clean -y \
	&& rm -rf /etc/apt/keyrings/* /etc/apt/sources.list.d/* /var/lib/apt/lists/* /tmp/* /var/tmp/ \
        && rm -rf /anzo_script.sh

#launcher
VOLUME ["/opt"]
ENTRYPOINT ["/usr/sbin/init-docker-systemd"]
#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisor.conf"]
