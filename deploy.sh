#!/bin/bash

set -e

echo "🚀 Deploying Redash on Kubernetes..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.example to .env and configure your environment variables."
    exit 1
fi

# Load environment variables
echo "📋 Loading environment variables..."
set -a
source .env
set +a

# Create namespace
echo "📁 Creating namespace..."
kubectl apply -f namespace.yaml

# Apply secrets (with environment variable substitution)
echo "🔐 Applying secrets..."
envsubst < secrets.yaml | kubectl apply -f -

# Apply configuration
echo "⚙️ Applying configuration..."
kubectl apply -f configmap.yaml

# Deploy PostgreSQL (Redash metadata)
echo "🐘 Deploying PostgreSQL (Redash metadata)..."
kubectl apply -f postgres.yaml

# Deploy PostgreSQL (Analytics data)
echo "📊 Deploying PostgreSQL (Analytics data)..."
kubectl apply -f postgres-analytics.yaml

# Deploy Redis
echo "🔴 Deploying Redis..."
kubectl apply -f redis.yaml

# Wait for databases to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n redash --timeout=300s
kubectl wait --for=condition=ready pod -l app=postgres-analytics -n redash --timeout=300s

# Initialize database and run migrations
echo "🗃️ Initializing database and running migrations..."
kubectl run --rm -it --restart=Never --image=redash/redash:10.1.0.b50633 --overrides='{"spec":{"containers":[{"name":"redash-db-init","image":"redash/redash:10.1.0.b50633","envFrom":[{"configMapRef":{"name":"redash-config"}},{"secretRef":{"name":"redash-secrets"}}],"command":["python","manage.py","database","create_tables"]}]}}' -n redash redash-db-init
kubectl run --rm -it --restart=Never --image=redash/redash:10.1.0.b50633 --overrides='{"spec":{"containers":[{"name":"redash-db-upgrade","image":"redash/redash:10.1.0.b50633","envFrom":[{"configMapRef":{"name":"redash-config"}},{"secretRef":{"name":"redash-secrets"}}],"command":["python","manage.py","db","upgrade"]}]}}' -n redash redash-db-upgrade

# Deploy Redash components
echo "📊 Deploying Redash components..."
kubectl apply -f redash.yaml

echo "✅ Deployment completed!"
echo ""
echo "📊 Database connections:"
echo "  - Redash metadata DB: postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}"
echo "  - Analytics data DB: postgres://${ANALYTICS_USER}:${ANALYTICS_PASSWORD}@postgres-analytics:5432/${ANALYTICS_DB}"
echo ""
echo "🔗 Wait for pods to be ready, then access Redash at:"
echo "💻 kubectl port-forward svc/redash-server -n redash 8080:8080"
