# Required Environment Variables:
# $DEEPL2_DISCORD_CHANNEL
# $DEEPL2_DISCORD_TOKEN
# $DEEPL2_S3_BUCKET_NAME
# $AWS_ACCESS_KEY_ID
# $AWS_SECRET_ACCESS_KEY

FROM alpine

ENV DEEPL2_YAMAX_VERSION=4.0

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /

RUN apk --no-cache --update add ffmpeg python3 python3-tkinter openmpi-bin psmisc \
    && apk --no-cache --virtual add .builddep python3-dev libffi-dev libopenmpi-dev openssl-dev git curl build-base \
    && pip3 install pipenv \
    && pip3 install awscli \
    && git clone https://github.com/Y-modify/deepl2 --depth 1 \
    && cd deepl2 \
    && git clone https://github.com/openai/baselines --depth 1 \
    && sed -i -e 's/mujoco,atari,classic_control,robotics/classic_control/g' baselines/setup.py \
    && pipenv install baselines/ --keep-outdated \
    && pipenv install --keep-outdated \
    && apk --purge del .builddep

ADD https://github.com/Y-modify/YamaX/releases/download/${DEEPL2_YAMAX_VERSION}/YamaX_${DEEPL2_YAMAX_VERSION}.urdf /deepl2/yamax.urdf

WORKDIR /deepl2

COPY run.sh /deepl2/run.sh
