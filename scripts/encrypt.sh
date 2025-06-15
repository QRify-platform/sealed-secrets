#!/bin/bash
# encrypt.sh <env> <secret-name> <key1=value1> [key2=value2] ...

set -e

ENV=$1
SECRET_NAME=$2
shift 2

# Ensure namespace exists
if ! kubectl get namespace "$ENV" >/dev/null 2>&1; then
  echo "🔧 Namespace '$ENV' not found. Creating it..."
  kubectl create namespace "$ENV"
fi

ARGS=""
for PAIR in "$@"; do
  ARGS="$ARGS --from-literal=${PAIR}"
done

kubectl create secret generic "$SECRET_NAME" --namespace="$ENV" $ARGS --dry-run=client -o json |
  kubeseal --cert=pub-cert.pem --format=yaml > "secrets/${ENV}/${SECRET_NAME}.yaml"

echo "🔐 Encrypted secret saved to secrets/${ENV}/${SECRET_NAME}.yaml"
