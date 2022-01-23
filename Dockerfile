FROM node:14-alpine
WORKDIR /workspace
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh
RUN npm i -g nodemon pm2
ADD  workspace /workspace
RUN adduser -D -g "" runner && \
    chown -R runner:runner /workspace
USER runner
CMD ["/bin/sh", "/workspace/run.sh"]