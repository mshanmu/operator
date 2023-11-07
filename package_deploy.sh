#!/bin/sh
helm package helm/minio-operator
ssh minio-m1 rm -f /home/mshanmu/helm_charts/operator-*.tgz
scp operator-*.tgz minio-m1:~/helm_charts
ssh mshanmu@minio-m1 'helm upgrade --create-namespace --install -n minio-operator minio-op ~/helm_charts/operator-*.tgz'
rm -f operator-*.tgz
