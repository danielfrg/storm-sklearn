(ns sklearn
  (:use     [backtype.storm.clojure])
  (:gen-class))

(def  sklearn
   [
    ;; spout configuration
    {"emit-cycle-spout" (shell-spout-spec
          ["python" "emit_cycle.py"]
          ["data"]
          )
    }
    ;; bolt configuration
    {"predict-bolt" (shell-bolt-spec
           {"emit-cycle-spout" :shuffle}
           ["python" "predict.py"]
           ["data" "prediction"]
           :p 2
           )
    }
  ]
)
