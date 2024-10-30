import gleam/uri.{type Uri}

pub type KubeConfig {
  KubeConfig(kubeapi_uri: Uri, token: String, cacert: String)
}
