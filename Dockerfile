FROM base-cpp:1.0
LABEL maintainer="elau89@gmail.com" \
      version="1.0" \
      description="Base image for C++ development with a few libraries"

# Install required build tools
RUN dnf install -y \
        bzip2-devel \
        glibc-devel \
        libtool \
        libunwind \
        libunwind-devel \
        readline-devel \
        zlib-devel && \
    dnf autoremove -y && \
    dnf clean all -y && \
    mkdir -p /tmp/packages

# Specify packages
ENV BOOST_DIR=boost-1.63.0 \
    GOOGLETEST_DIR=googletest-1.8.0 \
    POSTGRESQL_DIR=postgresql-9.6.2 \
    PROTOBUF_DIR=protobuf-3.2.0 \
    SPDLOG_DIR=spdlog-0.12.0 \
    ZEROMQ_DIR=zeromq-4.2.1

ENV BOOST_PKG=${BOOST_DIR}.tar.xz \
    GOOGLETEST_PKG=${GOOGLETEST_DIR}.tar.xz \
    POSTGRESQL_PKG=${POSTGRESQL_DIR}.tar.xz \
    PROTOBUF_PKG=${PROTOBUF_DIR}.tar.xz \
    SPDLOG_PKG=${SPDLOG_DIR}.tar.xz \
    ZEROMQ_PKG=${ZEROMQ_DIR}.tar.xz

# Copy Packages
COPY packages/ /tmp/packages/

# Build Boost
RUN cd /tmp/packages && \
    tar -xJf ${BOOST_PKG} && \
    cd ${BOOST_DIR} && \
    ./bootstrap.sh && \
    ./b2 -j 4 link=shared runtime-link=shared install

# Install Google Test
RUN cd /tmp/packages && \
    tar -xJf ${GOOGLETEST_PKG} && \
    cd ${GOOGLETEST_DIR} && \
    cmake . && make -j 4 && make install

# Build libpq
RUN cd /tmp/packages && \
    tar -xJf ${POSTGRESQL_PKG} && \
    cd ${POSTGRESQL_DIR} && \
    ./configure --prefix=/usr/local && \
    make -C src/interfaces install

# Install Protobufs
RUN cd /tmp/packages && \
    tar -xJf ${PROTOBUF_PKG} && \
    cd ${PROTOBUF_DIR} && \
    ./autogen.sh && ./configure && make -j 4 && make install

# Install Spdlog
RUN cd /tmp/packages && \
    tar -xJf ${SPDLOG_PKG} && \
    cd ${SPDLOG_DIR} && \
    cp -fr include/spdlog /usr/local/include

# Install ZeroMQ
RUN cd /tmp/packages && \
    tar -xJf ${ZEROMQ_PKG} && \
    cd ${ZEROMQ_DIR} && \
    ./autogen.sh && ./configure && make -j 4 && make install

RUN ldconfig -v && \
    rm -fr /tmp/packages

# Start up bash (will be overwritten when imported as a dependency)
CMD ["/bin/bash"]
