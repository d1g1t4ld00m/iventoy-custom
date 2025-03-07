# Stage 1: Build iPXE
FROM ubuntu:24.04 AS ipxe-builder
RUN apt-get update && apt-get install -y git make gcc
WORKDIR /ipxe
RUN git clone https://github.com/ipxe/ipxe.git . && \
    cd src && \
    make bin-x86_64-efi/ipxe.efi CONFIG=efi

# Stage 2: Build iVentoy
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y wget
WORKDIR /app
RUN wget https://github.com/ventoy/PXE/releases/download/v1.0.20/iventoy-1.0.20-linux-free.tar.gz && \
    tar -xzf iventoy-1.0.20-linux-free.tar.gz && \
    mv iventoy-1.0.20 iventoy
COPY --from=ipxe-builder /ipxe/src/bin-x86_64-efi/ipxe.efi /app/iventoy/boot/ipxe-x86_64.efi
WORKDIR /app/iventoy
EXPOSE 26000 16000 67/udp 69/udp
VOLUME ["/app/iventoy/iso"]
CMD ["/bin/sh", "-c", "./iventoy.sh start && tail -f /dev/null"]
