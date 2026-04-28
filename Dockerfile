FROM ruby:2.6.9-alpine3.15

ARG DOCS_BOOK_CLOUDFOUNDRY_REPO=https://github.com/cloudfoundry/docs-book-cloudfoundry.git
ARG DOCS_BOOK_CLOUDFOUNDRY_WORKDIR=/tmp/docs-book-cloudfoundry

LABEL org.opencontainers.image.title="Docs Book Cloud Foundry Container" \
      org.opencontainers.image.description="The container contains Ruby 2.6.9 and the functionality to run the Cloud Foundry documentation web server" \
      org.opencontainers.image.authors="Pascal Zimmermann <pascal.zimmermann@theiotstudio.com>"

ENV DOCS_BOOK_CLOUDFOUNDRY_WORKDIR=${DOCS_BOOK_CLOUDFOUNDRY_WORKDIR:-/tmp/docs-book-cloudfoundry}

WORKDIR $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR
COPY docker/files/Gemfile /tmp/Gemfile

COPY docker/files/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk add build-base git make g++ nodejs npm && \
    cd /tmp && git clone $DOCS_BOOK_CLOUDFOUNDRY_REPO && \
    cd $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR && rm $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR/Gemfile && \
    mv /tmp/Gemfile $DOCS_BOOK_CLOUDFOUNDRY_WORKDIR/Gemfile && \
    bundle install && \
    npm install -g browser-sync@2.29.3 && \
    chmod +x /usr/local/bin/entrypoint.sh

RUN ruby -i -0777 -p -e \
  'gsub(/def file_contents_include_binary_bytes\?\(filename\)/, \
        "def file_contents_include_binary_bytes?(filename)\n        return false if ::File.directory?(filename)")' \
  /usr/local/bundle/gems/middleman-core-4.1.10/lib/middleman-core/util/binary.rb && \
  grep -q "File.directory?" /usr/local/bundle/gems/middleman-core-4.1.10/lib/middleman-core/util/binary.rb && \
  echo "Patch 1 (binary.rb) applied" || (echo "PATCH 1 FAILED" && exit 1)

RUN ruby -i -0777 -p -e \
  'gsub(/next if resource\.binary\?/, \
        "next if resource.binary?\n        next if resource.file_descriptor && ::File.directory?(resource.file_descriptor[:full_path].to_s)")' \
  /usr/local/bundle/gems/middleman-core-4.1.10/lib/middleman-core/core_extensions/front_matter.rb && \
  grep -q "File.directory?" /usr/local/bundle/gems/middleman-core-4.1.10/lib/middleman-core/core_extensions/front_matter.rb && \
  echo "Patch 2 (front_matter.rb) applied" || (echo "PATCH 2 FAILED" && exit 1)

RUN ruby -i -0777 -p -e \
  'gsub(/def read\n/, \
        "def read\n      return nil if ::File.directory?(full_path)\n")' \
  /usr/local/bundle/gems/middleman-core-4.1.10/lib/middleman-core/sources.rb && \
  grep -q "File.directory?" /usr/local/bundle/gems/middleman-core-4.1.10/lib/middleman-core/sources.rb && \
  echo "Patch 3 (sources.rb) applied" || (echo "PATCH 3 FAILED" && exit 1)

# 4567 – bookbinder (Middleman) server
EXPOSE 4567

CMD ["/usr/local/bin/entrypoint.sh"]