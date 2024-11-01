import gleam/dynamic
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/option.{type Option, None, Some}
import gleam/result
import simplejson
import simplejson/jsonvalue

import kubeconfig/shared.{type KubeConfig}

import api/resources.{type KubeResourceType}

const verify_tls = False

pub type RequestError {
  NetworkError(dynamic.Dynamic)
  JsonError(jsonvalue.ParseError)
  CannotQueryNameWithoutNamespace
}

pub fn get(
  kube_config: KubeConfig,
  resource_type: KubeResourceType,
  name: String,
  namespace: String,
) -> Result(jsonvalue.JsonValue, RequestError) {
  // Doing let assert here because with Some(name) and Some(namespace) the build_api_path should never return an error
  let assert Ok(path) =
    build_api_path(resource_type, Some(name), Some(namespace))
  raw_request(kube_config, path)
}

pub fn get_all(
  kube_config: KubeConfig,
  resource_type: KubeResourceType,
  name: Option(String),
  namespace: Option(String),
) -> Result(jsonvalue.JsonValue, RequestError) {
  // Doing let assert here because with Some(name) and Some(namespace) the build_api_path should never return an error
  use path <- result.try(build_api_path(resource_type, name, namespace))
  raw_request(kube_config, path)
}

pub fn raw_request(
  kubeconfig: KubeConfig,
  path: String,
) -> Result(jsonvalue.JsonValue, RequestError) {
  // make query
  let assert Ok(base_req) = request.from_uri(kubeconfig.kubeapi_uri)
  let req =
    request.prepend_header(
      base_req,
      "Authorization",
      "Bearer " <> kubeconfig.token,
    )
    |> request.set_path(path)
  case httpc.dispatch(httpc.configure() |> httpc.verify_tls(verify_tls), req) {
    Ok(response.Response(body: body, headers: _headers, status: _status)) ->
      result.map_error(simplejson.parse(body), fn(e) { JsonError(e) })
    Error(e) -> Error(NetworkError(e))
  }
}

fn build_api_path(
  resource_type: KubeResourceType,
  name: Option(String),
  namespace: Option(String),
) -> Result(String, RequestError) {
  use #(name_segment, namespace_segment) <- result.try(case name, namespace {
    Some(_), None -> Error(CannotQueryNameWithoutNamespace)
    Some(name), Some(namespace) ->
      Ok(#("/" <> name, "/namespaces/" <> namespace))
    None, Some(namespace) -> Ok(#("", "/namespaces/" <> namespace))
    None, None -> Ok(#("", ""))
  })
  let api_version_segment =
    "/" <> resources.get_resource_api_version(resource_type)
  let api_name_segment = "/" <> resources.get_resource_api_name(resource_type)
  Ok(
    "/api"
    <> api_version_segment
    <> namespace_segment
    <> api_name_segment
    <> name_segment,
  )
}
