local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["pets-pvc"];

local k = import "k.libsonnet";

local pvc = {
  apiVersion: "v1",
  kind: "PersistentVolumeClaim",
  metadata:{
    name: params.name,
    namespace: env.namespace,
  },
  spec:{
    storageClassName: "pets-data",
    accessModes: [params.accessMode],
    resources: {
      requests: {
        storage: params.storage,
      },
    },
  },
};

std.prune(k.core.v1.list.new([pvc],))
