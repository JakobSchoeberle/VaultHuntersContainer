FROM openjdk:17.0.2-jdk-buster

#RUN apt-get update
RUN apt-get install -y unzip curl

#RUN mkdir -p /ServerFiles
WORKDIR /ServerFiles

RUN curl -Lo 'Vault-Hunters-server-files.zip' 'https://mediafilez.forgecdn.net/files/6803/163/Vault-Hunters-3rd-Edition-3.19.0.0-server-files.zip'
RUN unzip -u -o 'Vault-Hunters-server-files.zip'

ADD Preinitialization.sh .
RUN chmod 777 Preinitialization.sh
RUN ./Preinitialization.sh

ADD Run.sh .

EXPOSE 25565
EXPOSE 24454

VOLUME [ "/ServerFiles" ]

CMD [ "./Run.sh" ]