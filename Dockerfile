# FROM kosted/saar-training-jupyterlab:0.0.3
FROM kosted/maap-esa-jupyterlab:0.0.8
ENV ENV_NAME=sar-intro \
    CONDA_DIR=/opt/conda


# switch shell sh (default in Linux) to bash
SHELL ["/bin/bash", "-c"]

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
    'xlrd=2.0.*'  \
    gdal  \
    # cmake pdal python-pdal entwine
    geopandas  \
    rasterio  \
    xarray  \
    rioxarray  \
    pyproj  \
    cartopy  \
    ipyleaflet  \
    h5netcdf  \
    netcdf4 && \
    # npm cache clean --force
    #jupyter notebook --generate-config
    # source $CONDA_DIR/bin/activate && \
    echo  "$(which python)" && \
    $CONDA_DIR/envs/$ENV_NAME/bin/python -m ipykernel install --name $ENV_NAME --display-name "Python 3 ($ENV_NAME)" && \
    $CONDA_DIR/bin/conda clean --all -f -y && \
    conda clean -y --packages && \
    conda clean -y -a -f 

#RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc

ADD notebooks /projects/
ADD rootfs/root /root/
# Overwrite & add Labels
LABEL \
    "maintainer"="me@imansour.net" \
    "author"="Islam Mansour" 