// pub opaque type KubeResource {
//   Namespaced(name: String, resource_type: KubeResourceType, namespace: String)
//   ClusterWide(name: String, resource_type: KubeResourceType)
// }

pub type KubeResourceType {
  Pod
  Service
  PersistentVolumeClaim
  Secret
  ServiceAccount
  DaemonSet
  Deployment
  ReplicaSet
  StatefulSet
  CronJob
  Job
  Ingress
  Namespace
  Node
  PersistentVolume
  CustomResourceDefinition
  CustomResourceType(
    api_resource_name: String,
    api_version: String,
    namespaced: Bool,
  )
}

pub type ApiError {
  ResourceNotNamespaced
  ResourceNamespaced
  CannotUseNameWithAllNamespaces
}

// pub fn namespaced_resource(
//   resource_type: KubeResourceType,
//   name: String,
//   namespace: String,
// ) -> Result(KubeResource, ResourceError) {
//   case is_namespaced(resource_type) {
//     False -> Error(ResourceNotNamespaced)
//     True -> Ok(Namespaced(name, resource_type, namespace))
//   }
// }

// pub fn cluster_wide_resource(
//   resource_type: KubeResourceType,
//   name: String,
// ) -> Result(KubeResource, ResourceError) {
//   case is_namespaced(resource_type) {
//     True -> Error(ResourceNamespaced)
//     False -> Ok(ClusterWide(name, resource_type))
//   }
// }

// pub fn pod(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, Pod, namespace)
// }

// pub fn service(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, Service, namespace)
// }

// pub fn persistent_volume_claim(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, PersistentVolumeClaim, namespace)
// }

// pub fn secret(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, Secret, namespace)
// }

// pub fn service_account(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, ServiceAccount, namespace)
// }

// pub fn daemon_set(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, DaemonSet, namespace)
// }

// pub fn deployment(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, Deployment, namespace)
// }

// pub fn replica_set(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, ReplicaSet, namespace)
// }

// pub fn stateful_set(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, StatefulSet, namespace)
// }

// pub fn cron_job(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, CronJob, namespace)
// }

// pub fn job(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, Job, namespace)
// }

// pub fn ingress(name: String, namespace: String) -> KubeResource {
//   Namespaced(name, Ingress, namespace)
// }

// pub fn namespace(name: String) -> KubeResource {
//   ClusterWide(name, Namespace)
// }

// pub fn node(name: String) -> KubeResource {
//   ClusterWide(name, Node)
// }

// pub fn persistent_volume(name: String) -> KubeResource {
//   ClusterWide(name, PersistentVolume)
// }

// pub fn custom_resource_definition(name: String) -> KubeResource {
//   ClusterWide(name, CustomResourceDefinition)
// }

pub fn get_resource_api_version(resource_type: KubeResourceType) -> String {
  case resource_type {
    Namespace -> "v1"
    Node -> "v1"
    PersistentVolume -> "v1"
    Secret -> "v1"
    Service -> "v1"
    ServiceAccount -> "v1"
    PersistentVolumeClaim -> "v1"
    Pod -> "v1"
    CustomResourceDefinition -> "apiextensions.k8s.io/v1"
    ReplicaSet -> "apps/v1"
    StatefulSet -> "apps/v1"
    DaemonSet -> "apps/v1"
    Deployment -> "apps/v1"
    CronJob -> "batch/v1"
    Job -> "batch/v1"
    Ingress -> "networking.k8s.io/v1"
    CustomResourceType(_, version, _) -> version
  }
}

pub fn get_resource_api_name(resource_type: KubeResourceType) -> String {
  case resource_type {
    Namespace -> "namespaces"
    Node -> "nodes"
    PersistentVolume -> "persistentvolumes"
    Secret -> "secrets"
    Service -> "services"
    ServiceAccount -> "serviceaccounts"
    PersistentVolumeClaim -> "persistentvolumeclaims"
    Pod -> "pods"
    CustomResourceDefinition -> "customresourcedefinitions"
    ReplicaSet -> "replicasets"
    StatefulSet -> "statefulsets"
    DaemonSet -> "daemonsets"
    Deployment -> "deployments"
    CronJob -> "cronjobs"
    Job -> "jobs"
    Ingress -> "ingresses"
    CustomResourceType(name, _, _) -> name
  }
}

pub fn is_namespaced(resource_type: KubeResourceType) -> Bool {
  case resource_type {
    CronJob -> True
    CustomResourceDefinition -> False
    CustomResourceType(_, _, namespaced) -> namespaced
    DaemonSet -> True
    Deployment -> True
    Ingress -> True
    Job -> True
    Namespace -> False
    Node -> False
    PersistentVolume -> False
    PersistentVolumeClaim -> True
    Pod -> True
    ReplicaSet -> True
    Secret -> True
    Service -> True
    ServiceAccount -> True
    StatefulSet -> True
  }
}
