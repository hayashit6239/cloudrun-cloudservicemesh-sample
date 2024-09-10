variable region {
  type        = string
  description = "対象のリージョン"
}

variable artifact_registry_path {
  type        = string
  description = "Cloud Run にのせるコンテナイメージのパス Ex. asia-northeast1-docker.pkg.dev/{project_id}/xxx"
}

variable vpc {
  type        = string
  description = "Direct VPC Access 用の VPC"
}

variable subnet {
  type        = string
  description = "Direct VPC Access 用の Subnet"
}

variable service_account {
  type        = string
  description = "Cloud Run サービスのサービスアカウント"
}

variable backend_name {
  type        = string
  description = "Cloud Run サービスのバックエンドの名前"
}

variable port {
  type        = number
  description = "Cloud Run サービスの公開するポート"
}

variable mesh_id {
  type        = string
  description = "作成したサービスメッシュの ID"
}

variable domain_name {
  type        = string
  description = "Cloud DNS で設定したドメインメイン Ex. xxx.yy"
}