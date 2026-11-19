# mender-deviceconnect-liubiao

自维护的 Mender `deviceconnect` 服务（远程诊断（远程终端、端口转发、文件传输）），基于上游 [mendersoftware/mender-server](https://github.com/mendersoftware/mender-server) v4.1.4，只为让开源版能把审计事件交给自建审计服务 [mender-auditlogs-liubiao](https://git.skyrisai.com/yuzus/mender-auditlogs-liubiao)。

## 仓库约定

| 项目 | 内容 |
|---|---|
| 基线 | tag `upstream-v4.1.4` = 上游 `v4.1.4`（`89f60e8f1d9f2923e66f45d3bc8d21deb5fed475`），取自快照 fork [Lenoud/mender-server](https://github.com/Lenoud/mender-server)，保留上游完整历史 |
| 改动方式 | 除 `liubiao/` 目录外，仓库内容与上游 tag 完全一致。**不直接修改上游源码**，修改写成 `liubiao/patches/*.patch`，构建时应用 |
| 代码托管 | GitLab [yuzus/mender-deviceconnect-liubiao](https://git.skyrisai.com/yuzus/mender-deviceconnect-liubiao)（私有，`main` 受保护，改动走 MR）为主；GitHub [Lenoud/mender-deviceconnect-liubiao](https://github.com/Lenoud/mender-deviceconnect-liubiao)（公开）为快照，GitLab 合入后推送同步 |
| 构建 | GitLab CI，配置在 `liubiao/.gitlab-ci.yml`（项目设置的 CI 配置路径；根目录 `.gitlab-ci.yml` 是上游的，不使用）：`liubiao/verify.sh` 核对基线与补丁 SHA256 → `liubiao/Dockerfile` 应用补丁、跑公共包与本服务单测、构建镜像。MR 只构建，`main` 推送 Harbor |
| 镜像 | `harbor.skyrisai.com/develop/mender-deviceconnect-liubiao:upstream-4.1.4-main-<commit前8位>-<时间>`，二进制版本号 `v4.1.4+liubiao.<commit前8位>` |
| 部署 | `k8s_services` 的 `mender/values-prod.yaml` 中 `deviceconnect.image` |

`git diff upstream-v4.1.4` 只应看到 `liubiao/` 目录（以及 GitLab 初始化生成的 `.gitlab/merge_request_templates/`）；CI 用 `liubiao/verify.sh` 核对，基线写在 `liubiao/upstream.env`。

## 补丁

补丁按文件名顺序应用，SHA256 登记在 `liubiao/patches/SHA256SUMS`。

| 补丁 | 原因 |
|---|---|
| `0001-deviceconnect-allow-empty-tenant-auditlog.patch` | 上游 `client/workflows/client.go` 提交审计事件前要求身份带租户（`id.Tenant == ""` 即报错 `Context lacking tenant identity`）。开源版单租户没有租户 ID，打开 `DEVICECONNECT_ENABLE_AUDIT` 后事件提交必定失败，远程诊断（远程终端、端口转发、文件传输）操作随之失败（2026-11-19 生产实测）。补丁只保留“必须有身份”的检查，空租户原样提交；补充单测覆盖无租户身份 |

覆盖的审计事件：打开终端、关闭终端、开启/关闭端口转发、上传/下载文件。

## 本地验证补丁

```bash
sh liubiao/verify.sh
git apply liubiao/patches/*.patch
(cd backend && go test ./services/deviceconnect/client/workflows/)
git checkout -- backend
```

## 升级上游

1. 先同步 fork `Lenoud/mender-server` 拿到新 tag，再把新 tag 合入本仓库 `main`（保留上游历史，`liubiao/` 不会冲突），新建 `upstream-<tag>` 基线 tag。
2. `git apply --check` 确认补丁仍能应用；不能应用时按新代码重写补丁并重新跑单测。上游 main 已删除 deviceconnect 的审计代码（`f0fa5736`），升级到基于 main 的版本时要重新评估。
3. 更新 `liubiao/upstream.env`、`liubiao/patches/SHA256SUMS`、Dockerfile 中的 Go 镜像版本（与上游 `backend/services/*/Dockerfile` 一致），走 MR 合入后由 CI 构建新镜像。
