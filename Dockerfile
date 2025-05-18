FROM debian:bookworm-slim

LABEL description="ZeroTier One moon as Docker Image"

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends curl gpg ca-certificates iproute2 net-tools iputils-ping openssl procps \
    && mkdir -p /usr/share/keyrings/ \
    && curl -fsSL "https://download.zerotier.com/contact%40zerotier.com.gpg" | gpg --dearmor -o /usr/share/keyrings/zerotier.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/zerotier.gpg] https://download.zerotier.com/debian/bookworm bookworm main" >/etc/apt/sources.list.d/zerotier.list

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends zerotier-one

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# ZeroTier relies on UDP port 9993
EXPOSE 9993/udp

COPY setup-moon.sh /setup-moon.sh

ENTRYPOINT ["/setup-moon.sh"]
