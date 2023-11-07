#!/bin/sh
helm package helm/minio-operator
ssh minio-m1 rm -f /home/mshanmu/helm_charts/minio-operator-*.tgz
scp minio-operator-*.tgz minio-m1:~/helm_charts
ssh mshanmu@minio-m1 'helm upgrade --create-namespace --install -n minio-operator minio-op ~/helm_charts/minio-operator-*.tgz'
rm -f operator-*.tgz
