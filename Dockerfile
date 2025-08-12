FROM node:18
WORKDIR /app

COPY . .

RUN npm install && \
    apt-get update && \
    apt-get install -y unzip wget && \
    mkdir -p /opt/dynatrace/oneagent

ENV DT_HOME="/opt/dynatrace/oneagent"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
