FROM alpine:latest

RUN apk add jq
RUN apk add curl
RUN apk add bash

COPY testApi.sh /testApi.sh
COPY testBook1.json /testBook1.json

RUN chmod a+x /testApi.sh

CMD /testApi.sh