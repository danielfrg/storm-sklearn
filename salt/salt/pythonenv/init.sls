pyenv:
  pkg.installed:
    - names:
      - git
      - build-essential
  pyenv.installed:
    - name: miniconda-3.4.2
    - require:
      - pkg: pyenv

conda-env:
  conda.managed:
    - conda: /usr/local/pyenv/versions/miniconda-3.4.2/bin/conda
    - env_path: /usr/local/pyenv/versions/miniconda-3.4.2
    - requirements: salt://pythonenv/files/requirements.txt
    - require:
      - pyenv: pyenv
