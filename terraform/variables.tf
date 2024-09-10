variable project_id {
  type        = string
  description = "対象のプロジェクト ID"
}

variable region {
  type        = string
  description = "対象のリージョン"
}

variable artifact_registry_path {
  type        = string
  description = "Cloud Run にのせるコンテナイメージのパス Ex. asia-northeast1-docker.pkg.dev/{project_id}/xxx"
}

variable service_account {
  type        = string
  description = "Cloud Run サービスのサービスアカウント"
}

variable domain_name {
    type        = string
    description = "Cloud DNS で設定したドメインメイン Ex. xxx.yy"
}