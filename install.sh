# Obtenemos la ruta raíz del usuario actual
USER_HOME=$HOME

# Instalamos las dependencias del proyecto
pip install -r $USER_HOME/reev-host/entorno/requeriments.txt

$USER_HOME/miniconda/envs/reev-host/bin/uvicorn app:app --reload