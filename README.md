# 📊 Redash on Kubernetes

## 🚀 Quick Start

### 1. デプロイ実行
```bash
./deploy.sh
```

### 2. アクセス確認
```bash
# ポートフォワードでアクセス
kubectl port-forward svc/redash-server -n redash 5000:5000
```

ブラウザで `http://localhost:8080` にアクセス

## 📁 構成ファイル

- `📁 namespace.yaml` - Redash専用namespace
- `⚙️ configmap.yaml` - 環境変数設定
- `🐘 postgres.yaml` - PostgreSQL データベース
- `🔴 redis.yaml` - Redis キャッシュ
- `📊 redash.yaml` - Redash本体（server/worker/scheduler）
- `🚀 deploy.sh` - デプロイスクリプト

## 🛠️ 個別操作

### Pod状態確認
```bash
kubectl get pods -n redash
```

### ログ確認
```bash
kubectl logs -f deployment/redash-server -n redash
```

### 削除
```bash
kubectl delete namespace redash
```
