#!/bin/bash
# $BUCKET_NAME must be supplied from environ

git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch --all
[ -v DEEPL2_BRANCH_NAME ] && git checkout $DEEPL2_BRANCH_NAME
git pull
[ -v DEEPL2_COMMIT_ID ] && git checkout $DEEPL2_COMMIT_ID

commit_id=$(git rev-parse HEAD)
branch_name=$(git rev-parse --abbrev-ref HEAD)

ARCHIVE_NAME=${branch_name}_${commit_id}_$(date +%y%m%d_%H%M%S).tar.xz

patch << EOF
--- YamaX_4.0.urdf	2018-05-04 16:55:18.545944675 +0900
+++ yamax.urdf	2018-05-04 16:55:09.032611604 +0900
@@ -67,7 +67,13 @@
     <self_collide>False</self_collide>
     <material>Gazebo/Grey</material>
   </gazebo>
-  <link name="base_link"/>
+  <link name="base_link">
+    <inertial>
+      <origin xyz="0 0 0"/>
+      <mass value="0.0"/>
+      <inertia ixx="0.0" ixy="0" ixz="0" iyy="0.0" iyz="0" izz="0.0"/>
+    </inertial>
+  </link>
   <link name="body">
     <visual>
       <origin rpy="0 0 0" xyz="0 0 0"/>
EOF

[ -v DEEPL2_TIMESTEPS ] && timesteps=$DEEPL2_TIMESTEPS || timesteps=10000000

python3 train.py --monitor monitor --save model -se 500 --monitor-video 50000 --timesteps $timesteps --tensorboard ./tblog --discord \
  && tar Jcf $ARCHIVE_NAME monitor model tblog \
  && aws s3 cp $ARCHIVE_NAME s3://$BUCKET_NAME/
