include:
  - conda

build-essential:
  pkg.installed

sklearn:
  conda.managed:
    - name: /home/ubuntu/envs/sklearn
    - requirements: salt://pythonenv/files/requirements.txt
    - user: ubuntu
    - require:
      - sls: conda
