#!/bin/bash
# $BUCKET_NAME must be supplied from environ

ARCHIVE_NAME=train_archive_$(date +%y%m_%H%M%S).tar.xz

git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch --all
[ -v DEEPL2_BRANCH_NAME ] && git checkout $DEEPL2_BRANCH_NAME
git pull
[ -v DEEPL2_COMMIT_ID ] && git checkout $DEEPL2_COMMIT_ID

python3 train.py --monitor monitor --save model -se 500 --monitor-video 50000 --timesteps 10000000 --tensorboard ./tblog --discord \
  && tar Jcf $ARCHIVE_NAME monitor model tblog \
  && aws s3 cp $ARCHIVE_NAME s3://$BUCKET_NAME/
