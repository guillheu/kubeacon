import gleam/option.{None, Some}
import gleam/result
import gleam/uri.{type Uri, Uri}
import simplifile

import kubeconfig/shared.{type KubeConfig, KubeConfig}

const default_kube_token_path = "/var/run/secrets/kubernetes.io/serviceaccount/token"

const default_kube_ca_cert_path = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

pub const default_api_uri = Uri(
  scheme: Some("https"),
  userinfo: None,
  host: Some("kubernetes.default.svc"),
  port: None,
  path: "",
  query: None,
  fragment: None,
)

pub type InClusterConfigError {
  ServiceAccountTokenNotFound
  CaCertNotFound
}

fn get_serviceaccount_token() -> Result(String, InClusterConfigError) {
  use _ <- result.map_error(simplifile.read(default_kube_token_path))
  ServiceAccountTokenNotFound
}

fn get_ca_certificate() -> Result(String, InClusterConfigError) {
  use _ <- result.map_error(simplifile.read(default_kube_ca_cert_path))
  CaCertNotFound
}

pub fn load_config() -> Result(KubeConfig, InClusterConfigError) {
  use token <- result.try(get_serviceaccount_token())
  use cacert <- result.map(get_ca_certificate())
  KubeConfig(default_api_uri, token, cacert)
}
