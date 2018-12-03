FROM python:3-slim AS build
RUN apt-get update -qq && apt-get install -y curl gnupg2 jq bzip2 build-essential pkg-config libfuse-dev libsqlite3-dev
RUN pip install --upgrade --no-cache-dir setuptools pycrypto defusedxml requests apsw llfuse dugong
RUN TAG=$(curl -s "https://api.github.com/repos/s3ql/s3ql/releases/latest"|jq -r .tag_name -) \
 && FILE=$(echo "$TAG"|sed s/release/s3ql/) \
 && curl -L "https://github.com/s3ql/s3ql/releases/download/$TAG/$FILE.tar.bz2" | tar -xj \
 && cd $FILE \
 && python3 setup.py build_ext --inplace \
 && python3 setup.py install

FROM python:3-slim
RUN apt-get update -qq && apt-get install -y libfuse2 psmisc procps
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/
COPY ./run.sh /usr/local/bin/
RUN chmod 744 /usr/local/bin/run.sh
CMD ["/bin/sh","-c","/usr/local/bin/run.sh"]
