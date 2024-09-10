variable project_id {
  type        = string
  description = "対象のプロジェクト ID"
}

variable backend_name {
  type        = string
  description = "Cloud Run サービスのバックエンドの名前"
}

variable mesh_id {
  type        = string
  description = "作成したサービスメッシュの ID"
}

variable domain_name {
    type        = string
    description = "Cloud DNS で設定したドメインメイン Ex. xxx.yy"
}