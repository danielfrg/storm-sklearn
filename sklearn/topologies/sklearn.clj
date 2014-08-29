(ns sklearn
  (:use     [streamparse.specs])
  (:gen-class))

(defn sklearn [options]
   [
    ;; spout configuration
    {"emit-cycle-spout" (python-spout-spec
          options
          "spouts.emit_cycle.EmitCycle"
          ["data"]
          )
    }
    ;; bolt configuration
    {"predict-bolt" (python-bolt-spec
          options
          {"emit-cycle-spout" :shuffle}
          "bolts.predict.Predict"
          ["data" "prediction"]
          :p 2
          )
    }
  ]
)
