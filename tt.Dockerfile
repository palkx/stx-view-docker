# This container used as storage to deliver ready to deploy Target Track database
FROM node:12-alpine as build
WORKDIR /w
RUN apk --no-cache add --virtual builds-deps build-base python \
    nss \
    freetype \
    freetype-dev \
    ca-certificates
COPY package*.json ./
RUN npm i -q
COPY . .
ADD https://drive.google.com/u/0/uc?export=download&confirm=umKg&id=1Gl6UnjR80iTeO6GHO2O8zjBULhuHyoat tt.xml.gz
RUN gunzip < tt.xml.gz > tt.xml
RUN npm run start

FROM alpine:latest
WORKDIR /w
COPY --from=build /w/*.sql /w/
COPY --from=build /w/*.fasta /w/
COPY --from=build /w/entrypoint.sh /entrypoint.sh
RUN find . -type f -name '*.*' -exec gzip "{}" \; && chmod +x /entrypoint.sh
VOLUME [ "/w" ]
ENTRYPOINT [ "/entrypoint.sh" ]
