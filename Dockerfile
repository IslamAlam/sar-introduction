# FROM kosted/saar-training-jupyterlab:0.0.3
FROM kosted/maap-esa-jupyterlab:0.0.8
ENV ENV_NAME=base \
    CONDA_DIR=/opt/conda


ARG NB_USER="root"
ARG NB_UID="1000"
ARG NB_GID="100"
# ---- Miniforge installer ----
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)
# Check https://github.com/conda-forge/miniforge/releases
# Conda version
ARG conda_version="4.9.2"
# Miniforge installer patch version
ARG miniforge_patch_number="5"
# Miniforge installer architecture
ARG miniforge_arch="x86_64"
# Python implementation to use 
# can be either Miniforge3 to use Python or Miniforge-pypy3 to use PyPy
ARG miniforge_python="Miniforge3"

# Miniforge archive to install
ARG miniforge_version="${conda_version}-${miniforge_patch_number}"
# Miniforge installer
ARG miniforge_installer="${miniforge_python}-${miniforge_version}-Linux-${miniforge_arch}.sh"
# Miniforge checksum
ARG miniforge_checksum="49dddb3998550e40adc904dae55b0a2aeeb0bd9fc4306869cc4a600ec4b8b47c"

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
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/root \
    CONDA_VERSION="${conda_version}" \
    MINIFORGE_VERSION="${miniforge_version}"


ARG PYTHON_VERSION=3.8

# Prerequisites installation: conda, pip, tini
# Prerequisites installation: conda, pip, tini
RUN wget --quiet "https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/${miniforge_installer}" && \
    echo "${miniforge_checksum} *${miniforge_installer}" | sha256sum --check && \
    rm -r $CONDA_DIR  && \
    /bin/bash "${miniforge_installer}" -f -b -p $CONDA_DIR && \
    rm "${miniforge_installer}" && \
    # Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes \
    "conda=${CONDA_VERSION}" \
    'pip' \
    'tini=0.18.0' && \
    conda update --all --quiet --yes && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y && \
    rm -rf $HOME/.cache/yarn 

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
RUN conda install --quiet --yes \
    # FIXME: Workaround to fix #1215, to be removed once fixed in upstream
    'jedi=0.17.2' \
    'notebook=6.2.0' \
    'jupyterhub=1.3.0' \
    'jupyterlab=2.2.9' && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf $HOME/.cache/yarn


# switch shell sh (default in Linux) to bash
SHELL ["/bin/bash", "-c"]

RUN  \
    # Install Jupyter Notebook, Lab, and Hub
    # Generate a notebook server config
    # Cleanup temporary files
    # Correct permissions
    # Do all this in a single RUN command to avoid duplicating all of the
    # files across image layers when the permissions change  --quiet
    # $CONDA_DIR/bin/conda create -f --yes -n $ENV_NAME \
    $CONDA_DIR/bin/conda install -c conda-forge --name base --quiet --yes  \
    'beautifulsoup4=4.9.*' \
    'conda-forge::blas=*=openblas' \
    'bokeh=2.2.*' \
    'bottleneck=1.3.*' \
    'cloudpickle=1.6.*' \
    'cython=0.29.*' \
    'dask=2020.12.*' \
    'dill=0.3.*' \
    'h5py=3.1.*' \
    'ipywidgets=7.6.*' \
    'ipympl=0.5.*'\
    'matplotlib-base=3.3.*' \
    'numba=0.52.*' \
    'numexpr=2.7.*' \
    'pandas=1.1.*' \
    'patsy=0.5.*' \
    'protobuf=3.14.*' \
    'pytables=3.6.*' \
    'scikit-image=0.18.*' \
    'scikit-learn=0.24.*' \
    'scipy=1.5.*' \
    'seaborn=0.11.*' \
    'sqlalchemy=1.3.*' \
    'statsmodels=0.12.*' \
    'sympy=1.7.*' \
    'vincent=0.4.*' \
    'widgetsnbextension=3.5.*'\
    'xlrd=1.2.*' \
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
    netcdf4 \
    && \
    # npm cache clean --force
    #jupyter notebook --generate-config
    # source $CONDA_DIR/bin/activate && \
    echo  "$(which python)" && \
    #$CONDA_DIR/envs/$ENV_NAME/bin/python -m ipykernel install --name $ENV_NAME --display-name "Python 3 ($ENV_NAME)" && \
    $CONDA_DIR/bin/conda clean --all -f -y && \
    conda clean -y --packages && \
    conda clean -y -a -f && \
    # Activate ipywidgets extension in the environment that runs the notebook server
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
    'tensorflow==2.4.0' gdown 

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Julia installation
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)
# Check https://julialang.org/downloads/
ARG julia_version="1.5.3"
# SHA256 checksum
ARG julia_checksum="f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1"

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia \
    JULIA_VERSION="${julia_version}"

WORKDIR /tmp

# hadolint ignore=SC2046
RUN mkdir "/opt/julia-${JULIA_VERSION}" && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)"/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    echo "${julia_checksum} *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
    rm "/tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir "${JULIA_PKGDIR}" 
    #&& \
    #chown "${NB_USER}" "${JULIA_PKGDIR}"


# R packages including IRKernel which gets installed globally.
RUN conda install --quiet --yes \
    'r-base=4.0.3'  \
    'r-caret=6.0*' \
    'r-crayon=1.3*' \
    'r-devtools=2.3*' \
    'r-forecast=8.13*' \ 
    'r-hexbin=1.28*' \
    'r-htmltools=0.5*' \
    'r-htmlwidgets=1.5*' \ 
    'r-irkernel=1.1*' \
    'r-nycflights13=1.0*' \
    'r-randomforest=4.6*' \
    'r-rcurl=1.98*' \
    'r-rmarkdown=2.6*' \
    'r-rsqlite=2.2*' \
    'r-shiny=1.5*' \
    'r-tidyverse=1.3*' \
    'rpy2=3.3*' && \
    conda clean --all -f -y


# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
    julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\"" && \
    # move kernelspec out of home \
    mv "${HOME}/.local/share/jupyter/kernels/julia"* "${CONDA_DIR}/share/jupyter/kernels/" && \
    chmod -R go+rx "${CONDA_DIR}/share/jupyter" && \
    rm -rf "${HOME}/.local"


WORKDIR /projects


#RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc

ADD notebooks /projects/
ADD rootfs/root /root/
# Overwrite & add Labels
LABEL \
    "maintainer"="me@imansour.net" \
    "author"="Islam Mansour" 