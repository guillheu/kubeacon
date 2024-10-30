// import decode/zero as decode
// import envoy
// import gleam/erlang/process
// import gleam/http/request.{type Request}
// import gleam/http/response.{type Response}
// import gleam/httpc
// import gleam/io
// import gleam/uri

// pub fn main() {
//   let assert Ok(uri) = uri.parse(testing_api_url)
//   let assert Ok(request) = request.from_uri(uri)
//   case httpc.send(request) {
//     Error(e) -> {
//       io.debug(e)
//       Nil
//     }
//     Ok(response.Response(status: _, headers: _, body: body)) -> {
//       io.println(body)
//     }
//   }
// }

import gleam/io
import kubeconfig

pub fn main() {
  io.debug(kubeconfig.load())
}
