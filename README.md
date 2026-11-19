# mender-deviceconnect-liubiao

> 本项目由 GitLab 平台自动初始化。远程 `main` 已包含初始提交，请不要使用强制推送覆盖该提交。

## 新项目开始方式

新项目直接克隆远程仓库，然后开始开发：

```bash
git clone ssh://git@git.skyrisai.com:8781/yuzus/mender-deviceconnect-liubiao.git
cd mender-deviceconnect-liubiao
```

HTTPS 地址：`https://git.skyrisai.com/yuzus/mender-deviceconnect-liubiao.git`

## 已有本地仓库接入

操作前先确认工作区已提交且没有未保存变更。

### 方式一：变基到平台初始提交（推荐）

该方式保持线性历史：

```bash
git branch -M main
git remote add origin ssh://git@git.skyrisai.com:8781/yuzus/mender-deviceconnect-liubiao.git
git fetch origin
git rebase --root --onto origin/main
git push -u origin main
```

如果已经存在 `origin`，将 `git remote add` 替换为：

```bash
git remote set-url origin ssh://git@git.skyrisai.com:8781/yuzus/mender-deviceconnect-liubiao.git
```

### 方式二：允许一次无关历史合并

该方式会保留一个合并提交：

```bash
git branch -M main
git remote add origin ssh://git@git.skyrisai.com:8781/yuzus/mender-deviceconnect-liubiao.git
git pull origin main --allow-unrelated-histories --no-rebase
git push -u origin main
```

## 合并请求

项目默认 MR 模板位于：

```text
.gitlab/merge_request_templates/Default.md
```

创建合并请求时，GitLab 会自动填充该模板。
