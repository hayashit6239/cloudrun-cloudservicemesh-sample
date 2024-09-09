#!/bin/bash
set -e
set -o pipefail

arifact_registry_name=$1

log() {
    local level="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*"
}

log INFO "セットアップを開始します"

log INFO "引数のバリデーションを行います"

if [[ $arifact_registry_name ]]; then
    log INFO "Artifact Registry 名: $arifact_registry_name"
else
    log ERROR "Artifact Registry 名がありません、Ex asia-northeast1-docker.pkg.dev/xxx/yyy"
    exit 1
fi

log INFO "バックエンド用のコンテナをビルド&プッシュを行います"

docker build -f ./containers/service-backend-a/Dockerfile -t $arifact_registry_name/cloudrun/backend-a .

log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-a のビルドが成功しました"

docker push $arifact_registry_name/cloudrun/backend-a

log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-a のプッシュが成功しました"

docker build -f ./containers/service-backend-b/Dockerfile -t $arifact_registry_name/cloudrun/backend-b .

log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-b のビルドが成功しました"

docker push $arifact_registry_name/cloudrun/backend-b

log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-b のプッシュが成功しました"

log INFO "クライアント用のコンテナをビルド&プッシュを行います"

docker build -f ./containers/service-backend-for-frontend/Dockerfile -t $arifact_registry_name/cloudrun/backend-for-frontend .

log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-for-frontend のビルドが成功しました"

docker push $arifact_registry_name/cloudrun/backend-for-frontend

log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-for-frontend のプッシュが成功しました"