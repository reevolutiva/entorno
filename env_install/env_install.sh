echo "Instalando entorno reev-host"
conda env create -n reev-host -y -f environment.yml

# Activamos el entorno
source activate reev-host
conda activate reev-host
echo "Entorno reev-host instalado"