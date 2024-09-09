echo "Instalando entorno reev-host"
$HOME/miniconda/bin/conda env create -n reev-host -y -f environment.yml

# Activamos el entorno
source activate reev-host
$HOME/miniconda/bin/conda activate reev-host
echo "Entorno reev-host instalado"