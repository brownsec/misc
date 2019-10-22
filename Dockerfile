# Kali Linux Top10
# Docker image with kali-linux-top10 and a handful of other useful tools
# More info: https://medium.com/@infosec_stuff/kali-linux-in-a-docker-container-5a06311624eb
FROM kalilinux/kali-linux-docker

ENV DEBIAN_FRONTEND noninteractive
# do APT update
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get clean
# install Kali Linux "Top 10" metapackage and a couple "nice to have" tools
RUN apt-get -y install kali-linux-top10 exploitdb man-db dirb nikto wpscan w3af amass

# Dependencies
RUN apt-get install -y zenity mingw32 monodevelop xterm gnome-terminal default-jre default-jdk aapt dex2jar zlib1g-dev libmagickwand-dev imagemagick zipalign cowpatty bully lighttpd macchanger php-cgi isc-dhcp-server python3-dev python3-setuptools python-pip libssl-dev xprobe2 golang-go
RUN easy_install3 pip

# initialize Metasploit databse
RUN service postgresql start && msfdb init && service postgresql stop

VOLUME /root /var/lib/postgresql
# default LPORT for reverse shell
EXPOSE 4444

# knock
WORKDIR /root
RUN apt-get install -y python-dnspython && \
    curl -LOk -o knock.tar.gz https://github.com/guelfoweb/knock/archive/4.1.0.tar.gz && \
    tar -xzf knock.tar.gz && \
    rm knock.tar.gz && \
    cd /root/knock-4.1.0 && \
    python setup.py install
    
# Detect WAF
RUN git clone https://github.com/EnableSecurity/wafw00f /opt/wafw00f && \
    git clone https://github.com/techgaun/github-dorks /opt/github-dorks && \
    git clone https://github.com/maurosoria/dirsearch /opt/dirsearch && \
    git clone https://github.com/s0md3v/Arjun.git

RUN go get -u github.com/tomnomnom/assetfinder

RUN go get -u github.com/tomnomnom/gf
RUN echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc \
	&& mkdir /root/.gf
COPY gf-examples/*.json /root/.gf/  

WORKDIR /root
RUN go get -u github.com/tomnomnom/gron && \
    go get -u github.com/tomnomnom/httprobe && \
    go get -u github.com/tomnomnom/meg && \
    go get -u github.com/tomnomnom/unfurl && \
    go get github.com/tomnomnom/waybackurls && \
    go get -u github.com/tomnomnom/qsreplace.git

CMD ["/bin/bash"]
