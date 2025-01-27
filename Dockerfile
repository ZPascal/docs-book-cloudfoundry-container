FROM ruby:2.6.9-alpine3.15

ARG DOCS_BOOK_CLOUDFOUNDRY_REPO=https://github.com/cloudfoundry/docs-book-cloudfoundry.git
ARG DOCS_BOOK_CLOUDFOUNDRY_WORKDIR=/tmp/docs-book-cloudfoundry

LABEL org.opencontainers.image.title="Docs Book Cloud Foundry Container" \
      org.opencontainers.image.description="The container contains Ruby 2.6.9 and the functionality to run the Cloud Foundry documentation web server" \
      org.opencontainers.image.authors="Pascal Zimmermann <pascal.zimmermann@theiotstudio.com>"

WORKDIR $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR
COPY docker/files/Gemfile /tmp/Gemfile

RUN apk add build-base git make g++ nodejs && \
    cd /tmp && git clone $DOCS_BOOK_CLOUDFOUNDRY_REPO && \
    cd $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR && rm $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR/Gemfile && \
    mv /tmp/Gemfile $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR/Gemfile && \
    bundle install

EXPOSE 4567

CMD ["bundle", "exec", "bookbinder", "watch"]