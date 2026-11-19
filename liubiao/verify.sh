#!/bin/sh
# 核对本仓库仍是“上游原样源码 + liubiao/ 目录”，补丁已登记 SHA256 且能按顺序应用。CI 与本地均可运行。
set -eu
cd "$(git rev-parse --show-toplevel)"
. liubiao/upstream.env

git cat-file -e "${UPSTREAM_COMMIT}^{commit}"
git merge-base --is-ancestor "${UPSTREAM_COMMIT}" HEAD
# .gitlab/merge_request_templates/ 来自 GitLab 项目初始化，上游没有该目录。
extra="$(git diff --name-only "${UPSTREAM_COMMIT}" HEAD | grep -v -E '^(liubiao/|\.gitlab/merge_request_templates/)' || true)"
if [ -n "${extra}" ]; then
  echo "除 liubiao/ 外不允许修改上游文件，请改成 liubiao/patches 下的补丁：" >&2
  echo "${extra}" >&2
  exit 1
fi
echo "上游基线 ${UPSTREAM_TAG}（${UPSTREAM_COMMIT}）核对通过：只有 liubiao/ 与 MR 模板不同"

(cd liubiao/patches && sha256sum -c SHA256SUMS)
for patch in liubiao/patches/*.patch; do
  grep -q "  $(basename "${patch}")\$" liubiao/patches/SHA256SUMS || { echo "补丁未登记 SHA256：${patch}" >&2; exit 1; }
done

tree="$(mktemp -d)"
trap 'rm -rf "${tree}"' EXIT
git archive HEAD | tar -x -C "${tree}"
(cd "${tree}" && for patch in liubiao/patches/*.patch; do git apply --check "${patch}"; git apply "${patch}"; echo "可应用：${patch}"; done)
