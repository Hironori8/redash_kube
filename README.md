# 📊 Redash on Kubernetes

PostgreSQL、Redis、完全なRedash分析スタックを含むKubernetes上のRedashデプロイメント。

### コンポーネント詳細

#### 🖥️ Redash Server
- **役割**: WebUIとAPI提供
- **機能**: ダッシュボード表示、クエリエディタ、ユーザー認証
- **接続**: PostgreSQL（メタデータ）、Redis（セッション）

#### ⚡ Redash Worker  
- **役割**: クエリ実行エンジン
- **機能**: SQLクエリの非同期実行、データソース接続
- **接続**: PostgreSQL（分析データ）、Redis（ジョブキュー）

#### ⏰ Redash Scheduler
- **役割**: 定期実行管理
- **機能**: アラート、定期クエリ、レポート自動送信
- **接続**: PostgreSQL（メタデータ）、Redis（スケジュール管理）

#### 🗃️ PostgreSQL (メタデータ)
- **役割**: Redash内部データ保存
- **データ**: ユーザー、ダッシュボード、クエリ、設定

#### 🗃️ PostgreSQL (分析データ)  
- **役割**: 分析対象データ保存
- **データ**: 業務データ、分析用データ

#### 🔴 Redis
- **役割**: キャッシュとキューイング
- **データ**: セッション、ジョブキュー、クエリ結果キャッシュ

## ✨ 機能

### 📊 データビジュアライゼーション & 分析
- **インタラクティブダッシュボード**: リアルタイムダッシュボードの作成と共有
- **クエリエディタ**: シンタックスハイライト付きSQLクエリインターフェース
- **複数データソース**: PostgreSQL、MySQL、Redisなどに接続可能
- **グラフタイプ**: 棒グラフ、折れ線、面グラフ、円グラフ、ピボットテーブル、コホート分析
- **アラートシステム**: クエリ結果に基づくアラート設定

### 🔧 インフラストラクチャコンポーネント
- **高可用性**: Server、Worker、Schedulerの分離構成
- **永続ストレージ**: メタデータと分析データ用PostgreSQL
- **キャッシュレイヤー**: パフォーマンス向上のためのRedis
- **ヘルスモニタリング**: 内蔵ヘルスチェックとReadinessプローブ
- **スケーラブルアーキテクチャ**: Kubernetesネイティブデプロイメント

### 🛡️ セキュリティ & 管理
- **Namespace分離**: 専用Kubernetesネームスペース
- **シークレット管理**: 機密データの暗号化保存
- **環境設定**: 一元化された設定管理
- **リソース管理**: CPUとメモリのリミット/リクエスト

## 🚀 Quick Start

### 1. デプロイ実行
```bash
./deploy.sh
```

### 2. アクセス確認
```bash
# ポートフォワードでアクセス
kubectl port-forward svc/redash-server -n redash 8080:8080
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
