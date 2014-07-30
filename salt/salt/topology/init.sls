pickle:
  file.managed:
    - name: /var/data/storm/model.pickle
    - source: https://raw.githubusercontent.com/danielfrg/storm-sklearn/master/data/model.pickle
    - source_hash: md5=cdc7fc213c6066300e88d74bcfb37275
    - makedirs: True
