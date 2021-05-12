# FROM kosted/saar-training-jupyterlab:0.0.3
FROM kosted/maap-esa-jupyterlab:0.0.8
ENV ENV_NAME=sar-intro \
    CONDA_DIR=/opt/conda
RUN  \
    # Install Jupyter Notebook, Lab, and Hub
    # Generate a notebook server config
    # Cleanup temporary files
    # Correct permissions
    # Do all this in a single RUN command to avoid duplicating all of the
    # files across image layers when the permissions change  --quiet
    $CONDA_DIR/bin/conda create -f --yes -n $ENV_NAME \
    'python=3.8' \
    'pip' \
    'beautifulsoup4=4.9.*' \
    'conda-forge::blas=*=openblas' \
    'bokeh=2.3.*' \
    'bottleneck=1.3.*' \
    'cloudpickle=1.6.*' \
    'cython=0.29.*' \
    'dask=2021.3.*' \
    'dill=0.3.*' \
    'h5py=3.1.*' \
    'ipywidgets=7.6.*' \
    'ipympl=0.6.*'\
    'matplotlib-base=3.3.*' \
    'numba=0.53.*' \
    'numexpr=2.7.*' \
    'pandas=1.2.*' \
    'patsy=0.5.*' \
    'protobuf=3.15.*' \
    'pytables=3.6.*' \
    'scikit-image=0.18.*' \
    'scikit-learn=0.24.*' \
    'scipy=1.6.*' \
    'seaborn=0.11.*' \
    'sqlalchemy=1.4.*' \
    'statsmodels=0.12.*' \
    'sympy=1.7.*' \
    'vincent=0.4.*' \
    'widgetsnbextension=3.5.*'\
    'xlrd=2.0.*'  
    # $CONDA_DIR/bin/conda clean --all -f -y
    # npm cache clean --force
    #jupyter notebook --generate-config
    # source $CONDA_DIR/bin/activate && \

RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# switch shell sh (default in Linux) to bash
SHELL ["/bin/bash", "-c"]
RUN \
    # $CONDA_DIR/bin/conda init && \
    source $CONDA_DIR/bin/activate && \
    # $CONDA_DIR/bin/conda activate $ENV_NAME && \
    echo  "$(which python)" 
    # Cleanup - Remove all here since conda is not in path as of now
    # find /opt/conda/ -follow -type f -name '*.a' -delete && \
    # find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    # $CONDA_ROOT/bin/conda clean -y --packages && \
    # $CONDA_ROOT/bin/conda clean -y -a -f  && \
    # $CONDA_ROOT/bin/conda build purge-all
    # Install libraries for Geoprocessing (Geospatial, LiDAR, ) GDAL, GEOS, PDAL
RUN \
    source $CONDA_DIR/bin/activate && \
    conda activate $ENV_NAME && \
    conda install -n $ENV_NAME -y -c conda-forge gdal  \
    # cmake pdal python-pdal entwine
        geopandas rasterio xarray rioxarray pyproj cartopy ipyleaflet h5netcdf netcdf4 
    # Not needed? Install cuda-toolkit (e.g. for pytorch: https://pytorch.org/): https://anaconda.org/anaconda/cudatoolkit
    # conda install -y cudatoolkit=10.1 -c pytorch && \
    # Install cupy: https://cupy.chainer.org/
    # pip install --no-cache-dir cupy-cuda101
    # Install pycuda: https://pypi.org/project/pycuda
    # pip install --no-cache-dir pycuda
    # Install gpu utils libs
    # pip install --no-cache-dir gpustat py3nvml gputil
    # Install scikit-cuda: https://scikit-cuda.readthedocs.io/en/latest/install.html
    # pip install --no-cache-dir scikit-cuda
    # Install tensorflow gpu
    # TODO: tensorflow 2.3.1 installs tenorboard 2.4.0 with problems, use 2.3.0
    # pip install --no-cache-dir tensorflow==2.3.0 && \
    # Install ONNX GPU Runtime
    # TODO: 1.4.x is latest with cuda 10.1 support
    # pip install --no-cache-dir onnxruntime-gpu==1.4.0
    # Install pytorch gpu
    # https://pytorch.org/get-started/locally/
    # conda install -y pytorch -c pytorch
    # Install faiss gpu
    # conda install -y faiss-gpu -c pytorch
    # Update mxnet to gpu edition
    # pip install --no-cache-dir mxnet-cu101mkl==1.6.0.post0
    # install jax: https://github.com/google/jax#pip-installation
    # pip install --upgrade jax jaxlib==0.1.57+cuda101 -f https://storage.googleapis.com/jax-releases/jax_releases.html 
    # Install pygpu - Required for theano: http://deeplearning.net/software/libgpuarray/
    # conda install -y pygpu
    # Install lightgbm
    # pip install lightgbm --install-option=--gpu # --install-option="--opencl-include-dir=/usr/local/cuda/include/" --install-option="--opencl-library=/usr/local/cuda/lib64/libOpenCL.so" 
    # nvidia python ml lib
    # pip install --upgrade --force-reinstall nvidia-ml-py3
    # SpeedTorch: https://github.com/Santosh-Gupta/SpeedTorch
    # pip install --no-cache-dir SpeedTorch
    # Ipyexperiments - fix memory leaks
    # pip install --no-cache-dir ipyexperiments
RUN \
    python -m ipykernel install --user --name $ENV_NAME --display-name $ENV_NAME && \
    conda clean -y --packages && \
    conda clean -y -a -f 


# Overwrite & add Labels
LABEL \
    "maintainer"="me@imansour.net" 