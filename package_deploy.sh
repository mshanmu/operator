#!/bin/sh
helm package helm/minio-operator
ssh minio-m1 rm -f /home/mshanmu/helm_charts/minio-operator-*.tgz
scp minio-operator-*.tgz minio-m1:~/helm_charts
rm -f minio-operator-*.tgz
