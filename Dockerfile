# FROM kosted/saar-training-jupyterlab:0.0.3
FROM imansour/maap-esa-jupyterlab:0.0.14
ENV ENV_NAME=base \
    CONDA_DIR=/opt/conda


# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
        wget \
        ca-certificates \
        sudo \
        locales \
        fonts-liberation \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/root


ARG PYTHON_VERSION="3.8"

# Prerequisites installation: conda, pip, tini
# Prerequisites installation: conda, pip, tini
RUN set -x && \
    conda config --add channels conda-forge  && \
    conda config --set channel_priority strict  && \
    conda update conda --quiet --yes && \
    conda install --quiet --yes \
        mamba && \
    if [[ "${PYTHON_VERSION}" != "default" ]]; then mamba install --quiet --yes python="${PYTHON_VERSION}"; fi && \
    # Pin major.minor version of python
    mamba list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba list jupyterlab | grep '^jupyterlab ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba list notebook | grep '^notebook ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba install --quiet --yes \
        'pip' \
        'tini=0.18.0' && \
    mamba update --all --quiet --yes && \
    mamba list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    mamba clean --all -f -y && \
    rm -rf $HOME/.cache/yarn 

RUN  \
    # Install Jupyter Notebook, Lab, and Hub
    # Generate a notebook server config
    # Cleanup temporary files
    # Correct permissions
    # Do all this in a single RUN command to avoid duplicating all of the
    # files across image layers when the permissions change  --quiet
    # $CONDA_DIR/bin/conda create -f --yes -n $ENV_NAME \
    mamba install -c conda-forge --name base --quiet --yes  \
        'jupyterlab=2.1.4' \
        'altair' \
        'beautifulsoup4' \
        'bokeh' \
        'bottleneck' \
        'cloudpickle' \
        'conda-forge::blas=*=openblas' \
        'cython' \
        'dask' \
        'dill' \
        'h5py' \
        'ipympl'\
        'ipywidgets' \
        'matplotlib-base' \
        'numba' \
        'numexpr' \
        'pandas' \
        'patsy' \
        'protobuf' \
        'pytables' \
        'scikit-image' \
        'scikit-learn' \
        'scipy' \
        'seaborn' \
        'sqlalchemy' \
        'statsmodels' \
        'sympy' \
        'widgetsnbextension'\
        'xlrd' \
        'cmake' \
        'pdal' \
        'python-pdal' \
        'entwine' \
        'ipyleaflet'  \
        'gdal' \
        'pdal' \
        'pyproj' \
        'richdem' \
        'rasterio' \
        'xarray' \
        'zarr' \
        'rioxarray' \
        'netcdf4' \
        'h5netcdf' \
        'astropy' \
        'pyroSAR' \
        'pygmt' \
        'geopandas' \
        'cartopy' \
        'isce2' \
        'isce3' \
        'dask-geopandas' \
        'eoreader' \
        'fiona' \
        'shapely' \
        'leafmap' \
        'leafmaptools' && \
    # npm cache clean --force
    #jupyter notebook --generate-config
    # source $CONDA_DIR/bin/activate && \
    echo  "$(which python)" && \
    conda clean --all -f -y && \
    conda clean -y --packages && \
    conda clean -y -a -f && \
    #$CONDA_DIR/envs/$ENV_NAME/bin/python -m ipykernel install --name $ENV_NAME --display-name "Python 3 ($ENV_NAME)" && \
    mamba clean --all -f -y && \
    conda clean -y --packages && \
    conda clean -y -a -f 

RUN \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    # Also activate ipywidgets extension for JupyterLab
    # Check this URL for most recent compatibilities
    # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf "${HOME}/.cache/yarn" && \
    rm -rf "${HOME}/.node-gyp"


RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="${HOME}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot"


# Install Tensorflow
RUN pip install --quiet --no-cache-dir \
    'tensorflow==2.7' gdown 

WORKDIR /projects
ENV HOME=/projects


#RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc

ADD notebooks /projects/
ADD rootfs/root /root/
# ADD entrypoint.sh /maap-jupyter-ide/entrypoint.sh
# Overwrite & add Labels
LABEL \
    "maintainer"="me@imansour.net" \
    "author"="Islam Mansour" 