FROM openjdk:17.0.2-jdk-buster

#RUN apt-get update
RUN apt-get install -y unzip curl

#RUN mkdir -p /ServerFiles
WORKDIR /ServerFiles

RUN curl -Lo 'Vault-Hunters-server-files.zip' 'https://mediafilez.forgecdn.net/files/6807/189/Vault-Hunters-3rd-Edition-3.19.1.0-server-files.zip'
RUN unzip -u -o 'Vault-Hunters-server-files.zip'

ADD ops.json .
ADD whitelist.json .
ADD user_jvm_args.txt .

ADD Preinitialization.sh .
RUN chmod 777 Preinitialization.sh
RUN ./Preinitialization.sh

ADD Run.sh .
RUN chmod 777 Run.sh

RUN cd mods && curl -Lo 'canary-mc1.18.2-0.3.3.jar' 'https://mediafilez.forgecdn.net/files/5089/967/canary-mc1.18.2-0.3.3.jar'
RUN cd mods && curl -Lo 'noisium_legacy-forge-2.3.0+mc1.18.x.jar' 'https://mediafilez.forgecdn.net/files/5787/406/noisium_legacy-forge-2.3.0%2Bmc1.18.x.jar'
RUN cd mods && curl -Lo 'starlight-1.0.2+forge.546ae87.jar' 'https://mediafilez.forgecdn.net/files/3706/539/starlight-1.0.2%2Bforge.546ae87.jar'
RUN cd mods && curl -Lo 'ferritecore-4.2.2-forge.jar' 'https://mediafilez.forgecdn.net/files/4074/294/ferritecore-4.2.2-forge.jar'
RUN cd mods && curl -Lo 'lazydfu-1.0-1.18+.jar' 'https://mediafilez.forgecdn.net/files/3544/496/lazydfu-1.0-1.18%2B.jar'
RUN cd mods && curl -Lo 'modernfix-forge-5.18.0+mc1.18.2.jar' 'https://mediafilez.forgecdn.net/files/5399/365/modernfix-forge-5.18.0%2Bmc1.18.2.jar'
#RUN cd mods && curl -Lo 'dimthread-1.18.2-v1.0.5.jar' 'https://mediafilez.forgecdn.net/files/5480/307/dimthread-1.18.2-v1.0.5.jar'
RUN cd mods && curl -Lo 'Chunk-Pregenerator-1.18.2-4.4.5.jar' 'https://mediafilez.forgecdn.net/files/5632/169/Chunk-Pregenerator-1.18.2-4.4.5.jar'
RUN cd mods && curl -Lo 'CarbonConfig-1.18.2-1.2.7.1.jar' 'https://mediafilez.forgecdn.net/files/6540/82/CarbonConfig-1.18.2-1.2.7.1.jar'

EXPOSE 25565
EXPOSE 24454

VOLUME [ "/ServerFiles" ]

CMD [ "./run.sh" ] 