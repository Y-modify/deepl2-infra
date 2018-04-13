# Required Environment Variables:
# $DEEPL2_DISCORD_CHANNEL
# $DEEPL2_DISCORD_TOKEN
# $DEEPL2_S3_BUCKET_NAME
# $AWS_ACCESS_KEY_ID
# $AWS_SECRET_ACCESS_KEY

FROM alpine:3.5

ENV DEEPL2_YAMAX_VERSION=4.0

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /

RUN apk --update add ffmpeg python3 python3-tkinter freetype libpng psmisc openblas \
    && apk add --virtual .builddep openblas-dev gfortran freetype-dev libpng-dev linux-headers python3-dev libffi-dev openssl-dev git curl build-base \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --update-cache openmpi openmpi-dev \
    && pip3 install pipenv \
    && pip3 install awscli \
    && git clone https://github.com/Y-modify/deepl2 --depth 1 \
    && cd deepl2 \
    && git clone https://github.com/openai/baselines --depth 1 \
    && sed -i -e 's/mujoco,atari,classic_control,robotics/classic_control/g' baselines/setup.py \
    && pipenv install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.7.0-cp35-cp35m-linux_x86_64.whl --skip-lock \
    && pipenv install baselines/ --skip-lock \
    && pipenv install --skip-lock \
    && apk --purge del .builddep openmpi-dev \
    && rm -rf /var/cache/apk/*

ADD https://github.com/Y-modify/YamaX/releases/download/${DEEPL2_YAMAX_VERSION}/YamaX_${DEEPL2_YAMAX_VERSION}.urdf /deepl2/yamax.urdf

WORKDIR /deepl2

COPY run.sh /deepl2/run.sh
