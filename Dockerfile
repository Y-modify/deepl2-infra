# Required Environment Variables:
# $DEEPL2_DISCORD_CHANNEL
# $DEEPL2_DISCORD_TOKEN
# $DEEPL2_S3_BUCKET_NAME
# $AWS_ACCESS_KEY_ID
# $AWS_SECRET_ACCESS_KEY

FROM debian:stretch-slim

ENV DEEPL2_YAMAX_VERSION=4.0

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN buildDeps='libopenblas-dev libopenmpi-dev gfortran libfreetype6-dev libpng-dev python3-wheel python3-dev libffi-dev libssl-dev git build-essential'; \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends -qq openmpi-bin ssh ffmpeg python3 python3-tk python3-pip libfreetype6 libpng16-16 psmisc libopenblas-base \
    && apt-get install -y --no-install-recommends -qq $buildDeps \
    && pip3 install pipenv \
    && pip3 install awscli \
    && git clone https://github.com/Y-modify/deepl2 /deepl2 --depth 1 \
    && cd /deepl2 \
    && git clone https://github.com/openai/baselines --depth 1 \
    && sed -i -e 's/mujoco,atari,classic_control,robotics/classic_control/g' baselines/setup.py \
    && pipenv install baselines/ --skip-lock \
    && pipenv install --skip-lock \
    && rm baselines -r \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /deepl2

ADD https://github.com/Y-modify/YamaX/releases/download/${DEEPL2_YAMAX_VERSION}/YamaX_${DEEPL2_YAMAX_VERSION}.urdf /deepl2/yamax.urdf

COPY run.sh /deepl2/run.sh
