#!/bin/sh

cd /home/git

echo "Downloading gitlab ${TAG}"

sudo -u git -H git clone --depth 1 -b ${TAG} https://gitlab.com/gitlab-org/gitlab-ce.git gitlab -v
