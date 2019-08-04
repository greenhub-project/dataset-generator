FROM alpine:3.6

RUN apk add --no-cache --virtual mysql-client
RUN apk add --no-cache --virtual p7zip

# Set the working directory to /app
WORKDIR /app

RUN mkdir -p /app/data

# Copy the current directory contents into the container at /app
COPY . /app
