import api
import api/resources
import gleam/erlang/process
import gleam/io
import gleam/option.{None, Some}
import kubeconfig

pub fn main() {
  let assert Ok(kube_config) = kubeconfig.load()
  // io.debug(kube_config)
  let api_response =
    api.get_all(kube_config, resources.Pod, None, Some("default"))
  let _ = io.debug(api_response)
  process.sleep(10_000)
}
// TODO:
// make a jsonpath wrapper in api.gleam
