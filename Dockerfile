# Required Environment Variables:
# $DEEPL2_DISCORD_CHANNEL
# $DEEPL2_DISCORD_TOKEN
# $DEEPL2_S3_BUCKET_NAME
# $AWS_ACCESS_KEY_ID
# $AWS_SECRET_ACCESS_KEY

FROM ubuntu:xenial

ENV DEEPL2_YAMAX_VERSION=4.0

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends -qq ffmpeg python3-pip python3-tk libffi-dev libopenmpi-dev libssl-dev psmisc curl git \
    && pip3 install pipenv \
    && pip3 install awscli \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN git clone https://github.com/Y-modify/deepl2 --depth 1 \
    && cd deepl2 \
    && git clone https://github.com/openai/baselines --depth 1 \
    && sed -i -e 's/mujoco,atari,classic_control,robotics/classic_control/g' baselines/setup.py \
    && pipenv install baselines/ \
    && pipenv install

ADD https://github.com/Y-modify/YamaX/releases/download/${DEEPL2_YAMAX_VERSION}/YamaX_${DEEPL2_YAMAX_VERSION}.urdf /deepl2/yamax.urdf

WORKDIR /deepl2

COPY run.sh /deepl2/run.sh
