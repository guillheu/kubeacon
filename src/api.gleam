import gleam/dict
import gleam/dynamic
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/list
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
  JsonPathError(jsonvalue.JsonPathError)
  CannotQueryNameWithoutNamespace
  JsonFieldInvalidType(name: String, expected_type: String)
}

pub fn list(
  kube_config: KubeConfig,
  resource_type: KubeResourceType,
  name: Option(String),
  namespace: Option(String),
) -> Result(List(String), RequestError) {
  use json <- result.try(request(kube_config, resource_type, name, namespace))
  use json_items <- result.try(
    simplejson.jsonpath(json, ".items")
    |> result.map_error(fn(e) { JsonPathError(e) }),
  )
  use json_array <- result.try(case json_items {
    jsonvalue.JsonArray(json_array) -> Ok(json_array)
    _ -> Error(JsonPathError(jsonvalue.InvalidJsonPath))
  })
  Ok(
    result.values({
      use resource_json <- list.map(dict.values(json_array))
      case simplejson.jsonpath(resource_json, ".metadata.name") {
        Ok(jsonvalue.JsonString(name)) -> Ok(name)
        Ok(_) -> Error(JsonFieldInvalidType("metadata.name", "string"))
        Error(e) -> Error(JsonPathError(e))
      }
    }),
  )
}

pub fn request(
  kube_config: KubeConfig,
  resource_type: KubeResourceType,
  name: Option(String),
  namespace: Option(String),
) -> Result(jsonvalue.JsonValue, RequestError) {
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
