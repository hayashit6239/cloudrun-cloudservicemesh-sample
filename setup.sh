#!/bin/bash
set -e
set -o pipefail

arifact_registry_name=$1

log() {
    local level="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*"
}

log INFO "このセットアップでは下記の項目を実行します"
log INFO "・各アプリケーションのビルド & プッシュ"
log INFO "・Terraform の実行に渡す環境変数ファイルをコピーします"

log INFO "実行しますか？（yes or no）"

while read line
do
    if [[ $line = "yes" ]]; then
        log INFO "実行します"
        log INFO "========================="
        log INFO "引数のバリデーションを行います"

        if [[ $arifact_registry_name ]]; then
            log INFO "Artifact Registry 名: $arifact_registry_name"
        else
            log ERROR "Artifact Registry 名がありません、Ex asia-northeast1-docker.pkg.dev/xxx/yyy"
            exit 1
        fi
        log INFO "========================="
        log INFO "バックエンド用のコンテナをビルド&プッシュを行います"

        docker build -f ./containers/service-backend-a/Dockerfile -t $arifact_registry_name/cloudrun/backend-a .

        log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-a のビルドが成功しました"

        docker push $arifact_registry_name/cloudrun/backend-a

        log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-a のプッシュが成功しました"

        docker build -f ./containers/service-backend-b/Dockerfile -t $arifact_registry_name/cloudrun/backend-b .

        log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-b のビルドが成功しました"

        docker push $arifact_registry_name/cloudrun/backend-b

        log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/backend-b のプッシュが成功しました"

        log INFO "========================="
        log INFO "クライアント用のコンテナをビルド&プッシュを行います"

        docker build -f ./containers/service-backend-for-frontend/Dockerfile -t $arifact_registry_name/cloudrun/client-for-backend .

        log INFO "Docker イメージタグ名: $arifact_registry_name/client-for-backend のビルドが成功しました"

        docker push $arifact_registry_name/cloudrun/client-for-backend

        log INFO "Docker イメージタグ名: $arifact_registry_name/cloudrun/client-for-backend のプッシュが成功しました"

        log INFO "========================="
        log INFO "Terraform 実行時に渡す環境変数ファイルをコピーします。"

        cp terraform/env.tfvars.dummy terraform/env.tfvars
        cat terraform/env.tfvars 

        log INFO ""
        log INFO "========================="
        log INFO "セットアップを完了します。"
        exit 1
    else
        log ERROR "停止します"
        exit 1
    fi
done
