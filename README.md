# OpenCTI OSINT + Senda-Nexus Docker Stack

OpenCTIをベースに、内部コネクタ、デフォルトデータ、OSINTコネクタ、Senda-Nexusコネクタ、任意のXTM Oneコンポーネントを段階的に起動するためのDocker Compose構成です。

## 構成

| Profile | 内容 |
|---|---|
| default | Redis, OpenSearch, MinIO, RabbitMQ, OpenCTI, Worker |
| internal | import/export/analysis系の内部コネクタ |
| default-data | OpenCTI Datasets, MITRE |
| no-key | CISA KEV, FIRST EPSS, CVEListV5, Shodan InternetDB |
| api-key | AbuseIPDB, MalwareBazaar, URLhaus, AlienVault OTX |
| senda | Senda-Nexus Feed / Enrichment / Enrichment Live |
| xtm | XTM One / XTM Composer関連 |

## 初期セットアップ

```bash
cp .env.sample .env
chmod +x scripts/start.sh
```

`.env` 内の `CHANGE_ME` をすべて置き換えてください。最低限、以下は必須です。

```bash
OPENCTI_ADMIN_PASSWORD
OPENCTI_ADMIN_TOKEN
OPENCTI_ENCRYPTION_KEY
OPENCTI_HEALTHCHECK_ACCESS_KEY
MINIO_ROOT_PASSWORD
RABBITMQ_DEFAULT_PASS
```

UUIDは以下で生成できます。

```bash
uuidgen
```

ランダムキー例です。

```bash
openssl rand -base64 32
openssl rand -hex 32
```

## 起動順

まずOpenCTI本体だけを起動します。

```bash
./scripts/start.sh base
./scripts/start.sh status
```

OpenCTIがHealthyになったら、内部コネクタを起動します。

```bash
./scripts/start.sh internal
```

デフォルトデータを入れます。

```bash
./scripts/start.sh default-data
```

無料・APIキー不要のOSINTコネクタを起動します。

```bash
./scripts/start.sh no-key
```

APIキー系はキー設定後に起動してください。

```bash
./scripts/start.sh api-key
```

Senda-Nexusは `OPENCTI_SENDA_TOKEN` と `SENDA_NEXUS_API_TOKEN` 設定後に起動します。

```bash
./scripts/start.sh senda
./scripts/start.sh logs-senda
```

XTM One関連は必要な場合のみ最後に起動します。

```bash
./scripts/start.sh xtm
```

すべてのprofileを一括で起動する場合は `all` を使います。

```bash
./scripts/start.sh all
```

`all` は以下の順に起動します。

```text
base -> internal -> default-data -> no-key -> api-key -> senda -> xtm
```

## 状態確認

```bash
./scripts/start.sh status
./scripts/start.sh status-all
curl -s http://localhost:9200/_cluster/health?pretty
curl -s "http://localhost:8080/health?health_access_key=${OPENCTI_HEALTHCHECK_ACCESS_KEY}"
```

## 停止

全profileを含めて停止します。volumeは削除しません。

```bash
./scripts/down.sh all
```

`start.sh` 側からも同じ操作ができます。

```bash
./scripts/start.sh down-all
```

default profileだけ止める場合は以下です。

```bash
./scripts/down.sh default
```

停止後に残った `xtm-*` コンテナも削除したい場合は以下です。volumeは削除しません。

```bash
./scripts/down.sh clean
```

ホストをshutdownする前に、Compose外で残った `xtm-*` コンテナだけ止めたい場合は以下を使えます。

```bash
./scripts/start.sh stop-xtm
```

## Senda-Nexus確認

```bash
./scripts/start.sh senda
./scripts/start.sh logs-senda
```

正常系ログの目安です。

```text
Initiate work
Update action expectations
Senda-Nexus Feed sending bundle to queue
Schedule next run of connector
```

