# 動作確認手順

CloudWatch エージェントが syslog と audit ログを CloudWatch Logs に転送できているかを確認する。

- 対象: dev 環境（prd のときは `dev` を `prd` に読み替える）
- リージョン: アジアパシフィック（東京） ap-northeast-1
- 前提: `terraform apply` 済みで、Systems Manager のフリートマネージャーでインスタンスの Ping ステータスが「オンライン」になっている

## 1. インスタンスの中を確かめる

### 1-1. Session Manager で接続する

1. マネジメントコンソールで **EC2** → **インスタンス** を開く
2. `dev-cloud-watch-agent-test-ec2` を選び、**接続** を押す
3. **Session Manager** タブで **接続** を押す

以降のコマンドは、ブラウザに開いたシェルで実行する。

### 1-2. user_data が最後まで流れたか確認する

```bash
sudo tail -n 30 /var/log/cloud-init-output.log
```

- [ ] `fetch-config ... -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json` が実行されている
- [ ] `Configuration validation succeeded` が出ている
- [ ] 最後に `Cloud-init v. ... finished` が出ている

### 1-3. エージェントの設定ファイルを確認する

```bash
sudo cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

- [ ] `/var/log/messages` の送り先が `/dev/cloud-watch-agent-test/syslog` になっている
- [ ] `/var/log/audit/audit.log` の送り先が `/dev/cloud-watch-agent-test/audit` になっている

### 1-4. エージェントの状態を確認する

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
```

- [ ] `"status": "running"` になっている
- [ ] `"configstatus": "configured"` になっている

### 1-5. rsyslog と auditd の状態を確認する

```bash
systemctl is-active rsyslog auditd
```

- [ ] 2行とも `active` になっている

## 2. テスト用のログを出す

syslog に目印の文字列を書き込む。

```bash
logger -t cwagent-test "syslog check"
```

sudo でコマンドを実行し、audit ログに `USER_CMD` のイベントを記録させる。

```bash
sudo ls /root
```

## 3. ログファイルに書き込まれたか確かめる

### 3-1. syslog（/var/log/messages）

```bash
sudo grep "cwagent-test" /var/log/messages
```

- [ ] 次のような行が出る

```
Oct  3 10:15:42 ip-10-0-x-x cwagent-test[12345]: syslog check
```

### 3-2. audit ログ（/var/log/audit/audit.log）

`-ts recent` は直近10分に絞る指定。`-i` は16進の値を読める形にする指定。

```bash
sudo ausearch -m USER_CMD -ts recent -i
```

- [ ] `type=USER_CMD` で、`cmd=ls /root` を含む行が出る

## 4. CloudWatch Logs に届いたか確かめる

反映まで1分ほどかかることがある。出てこないときは少し待ってから再読み込みする。

### 4-1. ロググループを確認する

1. マネジメントコンソールで **CloudWatch** → **ログ** → **ロググループ** を開く
2. 検索欄に `cloud-watch-agent-test` と入れる

- [ ] `/dev/cloud-watch-agent-test/syslog` と `/dev/cloud-watch-agent-test/audit` の2つがある
- [ ] どちらも保持期間が「1か月」になっている

### 4-2. syslog が届いたか確認する

1. `/dev/cloud-watch-agent-test/syslog` を開く
2. 現在のインスタンス ID（`i-xxxx`）のログストリームを開く
3. 検索欄に `cwagent-test` と入れる

- [ ] 手順3-1と同じ行が出る

### 4-3. audit ログが届いたか確認する

1. `/dev/cloud-watch-agent-test/audit` を開く
2. 現在のインスタンス ID のログストリームを開く
3. 検索欄に `USER_CMD` と入れる

- [ ] 手順2で実行した sudo の時刻に `type=USER_CMD` の行が出る
