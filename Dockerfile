FROM java:8u45

ENV ES_PKG_NAME elasticsearch-1.6.0

RUN \
  apt-get update &&\
  apt-get install -y automake perl

# Install Elasticsearch.
RUN \
  cd / && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch

RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz &&\
  tar xvf mecab-0.996-ko-0.9.2.tar.gz &&\
  cd /opt/mecab-0.996-ko-0.9.2 &&\
  ./configure &&\
  make &&\
  make check &&\
  make install &&\
  ldconfig

RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-1.6.1-20140814.tar.gz &&\
  tar xvf mecab-ko-dic-1.6.1-20140814.tar.gz &&\
  cd /opt/mecab-ko-dic-1.6.1-20140814 &&\
  ./autogen.sh &&\
  ./configure &&\
  make &&\
  make install

ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

RUN \
  cd /opt &&\
  wget https://mecab.googlecode.com/files/mecab-java-0.996.tar.gz &&\
  tar xvf mecab-java-0.996.tar.gz &&\
  cd /opt/mecab-java-0.996 &&\
  sed -i 's|/usr/lib/jvm/java-6-openjdk/include|/usr/lib/jvm/java-8-oracle/include|' Makefile &&\
  make &&\
  cp libMeCab.so /usr/local/lib

# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

RUN /elasticsearch/bin/plugin --install analysis-mecab-ko-0.17.0 --url https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.17.0.zip

# Define working directory.
WORKDIR /data

# Define default command.
CMD /elasticsearch/bin/elasticsearch -Djava.library.path=/usr/local/lib

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300
