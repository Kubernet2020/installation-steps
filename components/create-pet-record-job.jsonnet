local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["create-pet-record-job"];

local k = import "k.libsonnet";

// This job converts our dataset to TFRecord format which is what TensorFlow
// Object Detection API uses

local createPetRecordJob = {
apiVersion: "batch/v1",
  kind: "Job",
  metadata: {
    name: params.name,
    namespace: env.namespace,
  },
  spec: {
    nodeName: "vm2-wokernode1",
    template: {
      spec: {
        nodeSelector:{
          shi: "big",
        },
        containers: [{
          name: "create-tf-record",
          image: params.image,
          imagePullPolicy: "IfNotPresent",
          nodeName: "vm2-wokernode1",
          command: ["python", "/models/research/object_detection/dataset_tools/create_pet_tf_record.py"],
          args: ["--label_map_path=/models/research/object_detection/data/pet_label_map.pbtxt",
                 "--data_dir=" + params.dataDirPath,
                 "--output_dir=" + params.outputDirPath],
          volumeMounts: [{
              mountPath: params.mountPath,
              name: "pets-data",
          },],
          },],
        volumes: [{
            name: "pets-data",
            persistentVolumeClaim: {
              claimName: params.pvc,
            },
        },],
        restartPolicy: "Never",
      },
    },
    backoffLimit: 4,
  },
};

std.prune(k.core.v1.list.new([createPetRecordJob,]))
