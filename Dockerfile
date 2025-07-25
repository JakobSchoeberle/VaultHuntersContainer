#FROM openjdk:17.0.2-jdk-buster
FROM container-registry.oracle.com/graalvm/native-image:17

#RUN apt-get update
#RUN apt-get install -y unzip curl
RUN microdnf install curl
RUN microdnf install unzip

#RUN mkdir -p /ServerFiles
WORKDIR /ServerFiles

RUN curl -Lo 'Vault-Hunters-server-files.zip' 'https://mediafilez.forgecdn.net/files/6807/189/Vault-Hunters-3rd-Edition-3.19.1.0-server-files.zip'
RUN unzip -u -o 'Vault-Hunters-server-files.zip'

ADD ops.json .
ADD user_jvm_args.txt .

ADD Preinitialization.sh .
RUN chmod 777 Preinitialization.sh
RUN ./Preinitialization.sh

ADD Run.sh .
RUN chmod 777 Run.sh

RUN cd mods
RUN curl -Lo 'canary-mc1.18.2-0.3.3.jar' 'https://mediafilez.forgecdn.net/files/5089/967/canary-mc1.18.2-0.3.3.jar'
RUN curl -Lo 'noisium_legacy-forge-2.3.0+mc1.18.x.jar' 'https://mediafilez.forgecdn.net/files/5787/406/noisium_legacy-forge-2.3.0%2Bmc1.18.x.jar'
RUN curl -Lo 'starlight-1.0.2+forge.546ae87.jar' 'https://mediafilez.forgecdn.net/files/3706/539/starlight-1.0.2%2Bforge.546ae87.jar'
RUN curl -Lo 'ferritecore-4.2.2-forge.jar' 'https://mediafilez.forgecdn.net/files/4074/294/ferritecore-4.2.2-forge.jar'
RUN curl -Lo 'lazydfu-1.0-1.18+.jar' 'https://mediafilez.forgecdn.net/files/3544/496/lazydfu-1.0-1.18%2B.jar'
RUN curl -Lo 'modernfix-forge-5.18.0+mc1.18.2.jar' 'https://mediafilez.forgecdn.net/files/5399/365/modernfix-forge-5.18.0%2Bmc1.18.2.jar'

EXPOSE 25565
EXPOSE 24454

VOLUME [ "/ServerFiles" ]

CMD [ "./run.sh" ]