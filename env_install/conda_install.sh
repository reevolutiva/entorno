
# Descargamos conda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh

# Instalamos conda
bash miniconda.sh -b -p $HOME/miniconda

# Añadimos conda al PATH
echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc

# Recargamos el archivo de configuración de la terminal
source $HOME/.bashrc

rm miniconda.sh