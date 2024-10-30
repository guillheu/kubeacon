import gleam/result
import gleam/uri.{type Uri, Uri}

import kubeconfig/in_cluster
import kubeconfig/out_cluster
import kubeconfig/shared.{type KubeConfig}

pub type ConfigError {
  UnknownEnvironment
}

pub fn load() -> Result(KubeConfig, ConfigError) {
  use _in_cluster_error <- result.try_recover(in_cluster.load_config())
  use _out_cluster_error <- result.map_error(out_cluster.load_config())
  UnknownEnvironment
}

pub fn get_kube_api_uri(config: KubeConfig) -> Uri {
  config.kubeapi_uri
}
