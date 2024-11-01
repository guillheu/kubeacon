import envoy
import glaml
import gleam/bit_array
import gleam/result
import gleam/uri
import kubeconfig/shared.{type KubeConfig, KubeConfig}
import simplifile

const default_kubeconfig_path_from_homedir = "/.kube/config"

pub type OutClusterConfigError {
  KubeConfigFileNotFound
  KubeConfigPathNotFound
  InvalidKubeConfigYamlFormat
}

fn get_kubeconfig_file_content() -> Result(String, OutClusterConfigError) {
  use kubeconfig_path <- result.try(get_kubeconfig_path())
  use _ <- result.map_error(simplifile.read(kubeconfig_path))
  KubeConfigFileNotFound
}

fn get_kubeconfig_path() -> Result(String, OutClusterConfigError) {
  case envoy.get("KUBECONFIG") {
    Ok(config_path) -> Ok(config_path)
    Error(_) ->
      case envoy.get("HOME") {
        Ok(home_dir) -> Ok(home_dir <> default_kubeconfig_path_from_homedir)
        Error(_) -> Error(KubeConfigPathNotFound)
      }
  }
}

pub fn load_config() -> Result(KubeConfig, OutClusterConfigError) {
  use kubeconfig_content <- result.try(get_kubeconfig_file_content())
  case glaml.parse_string(kubeconfig_content) {
    Ok(doc) -> {
      let root_node = glaml.doc_node(doc)
      use encoded_cacert <- result.try(get_yaml_string(
        root_node,
        "clusters.#0.cluster.certificate-authority-data",
      ))
      use token <- result.try(get_yaml_string(root_node, "users.#0.user.token"))
      use kubeapi_uri_string <- result.try(get_yaml_string(
        root_node,
        "clusters.#0.cluster.server",
      ))
      use cacert <- result.try(decode_cert(encoded_cacert))
      case uri.parse(kubeapi_uri_string) {
        Ok(kubeapi_uri) ->
          Ok(KubeConfig(kubeapi_uri: kubeapi_uri, token: token, cacert: cacert))
        Error(_) -> Error(InvalidKubeConfigYamlFormat)
      }
    }
    Error(_) -> Error(InvalidKubeConfigYamlFormat)
  }
}

fn decode_cert(cacert: String) -> Result(String, OutClusterConfigError) {
  case bit_array.base64_decode(cacert) {
    Ok(decoded) ->
      result.map_error(bit_array.to_string(decoded), fn(_) {
        InvalidKubeConfigYamlFormat
      })
    Error(_) -> Error(InvalidKubeConfigYamlFormat)
  }
}

fn get_yaml_string(
  node: glaml.DocNode,
  path: String,
) -> Result(String, OutClusterConfigError) {
  case glaml.sugar(node, path) {
    Ok(glaml.DocNodeStr(result)) -> Ok(result)
    _ -> Error(InvalidKubeConfigYamlFormat)
  }
}
