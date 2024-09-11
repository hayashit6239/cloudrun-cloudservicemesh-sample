# 概要
[Cloud Service Mesh + Cloud Run でサービスメッシュ構築](https://zenn.dev/t_hayashi/articles/e6d51f3a4c95f3)という記事のサンプルリポジトリです。

# 利用手順
上記を参照ください。

## 前提
* サービスアカウントおよび Cloud IAM 周りはご自身でご準備ください。

## 準備
* `terraform/env.tfvars.dummy` に必要な情報を記載します
* `setup.sh` を実行します
  * Cloud Run サービスにのせるアプリケーションのコンテナイメージを格納する Artifact Registry のパスを引数に渡します
  * Ex. asia-northeast1-docker.pkg.dev/xxx/yyy

```bash:terraform
bash setup.sh asia-northeast1-docker.pkg.dev/xxx/yyy
```

## 検証① 
* `terraform/main.tf` を実行します。
  * `Backend-a` と `Backend-b` をデプロイします。

```bash:Terminal
cd terraform
terraform init -var-file=env.tfvars -upgrade
terraform apply -var-file=env.tfvars
```

* クライアント用の Cloud Run サービスをデプロイします。

```bash:Terminal
gcloud beta run deploy service-client-for-backend \
    --no-allow-unauthenticated \
    --region={region} \
    --image={service-client-for-backend image} \
    --network={vpc name} \
    --subnet={subnet name} \
    --mesh={mesh id} \
    --port=8080 \
    --env-vars-file=../containers/service-backend-for-frontend/env_val.yaml
```

## 検証②
* `Backend-b` はデプロイ済みの想定です。

## 検証③
* クライアント用の Cloud Run サービスをデプロイします。

```bash:Terminal
gcloud beta run deploy service-backend-c \
    --no-allow-unauthenticated \
    --region={region} \
    --image={service-client-for-backend image} \
    --network={vpc name} \
    --subnet={subnet name} \
    --mesh={mesh id} \
    --port=8081 \
    --env-vars-file=../containers/service-c/env_val.yaml
```

* `terraform/main.tf` の `module.service-backend-c` のコメントアウトをはずします。

```bash:Terminal
terraform apply -var-file=env.tfvars
```
