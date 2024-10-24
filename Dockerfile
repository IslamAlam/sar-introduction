# FROM kosted/saar-training-jupyterlab:0.0.3
# FROM imansour/maap-esa-jupyterlab:0.0.14
ARG ROOT_CONTAINER=ubuntu:jammy

FROM $ROOT_CONTAINER

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    fonts-liberation \
    locales \
    # - pandoc is used to convert notebooks to html files
    #   it's not present in arm64 ubuntu image, so we install it here
    pandoc \
    # - run-one - a wrapper script that runs no more
    #   than one unique  instance  of  some  command with a unique set of arguments,
    #   we use `run-one-constantly` to support `RESTARTABLE` option
    run-one \
    sudo \
    # - tini is installed as a helpful container entrypoint that reaps zombie
    #   processes and such of the actual executable we want to start, see
    #   https://github.com/krallin/tini#why-tini for details.
    tini \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen


# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH="${CONDA_DIR}/bin:${PATH}" \
    HOME=/root
    
ENV ENV_NAME=base


# Layer cleanup script
# Make clean-layer and fix-permissions executable
COPY resources/scripts/fix-permissions.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/fix-permissions.sh \
    && ln -s /usr/local/bin/fix-permissions.sh /usr/local/bin/fix-permissions
    
COPY resources/scripts/clean-layer.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/clean-layer.sh \
    && ln -s /usr/local/bin/clean-layer.sh /usr/local/bin/clean-layer


# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
   # Add call to conda init script see https://stackoverflow.com/a/58081608/4413446
   echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc


ARG PYTHON_VERSION=3.11

# Download and install Micromamba, and initialize the Conda prefix.
#   <https://github.com/mamba-org/mamba#micromamba>
#   Similar projects using Micromamba:
#     - Micromamba-Docker: <https://github.com/mamba-org/micromamba-docker>
#     - repo2docker: <https://github.com/jupyterhub/repo2docker>
# Install Python, Mamba, and jupyter_core
# Cleanup temporary files and remove Micromamba
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
COPY initial-condarc "${CONDA_DIR}/.condarc"
WORKDIR /tmp
RUN set -x && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        # Should be simpler, see <https://github.com/mamba-org/mamba/issues/1437>
        arch="64"; \
    fi && \
    # https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html#linux-and-macos
    wget --progress=dot:giga -O - \
        "https://micro.mamba.pm/api/micromamba/linux-${arch}/latest" | tar -xvj bin/micromamba && \
    PYTHON_SPECIFIER="python=${PYTHON_VERSION}" && \
    if [[ "${PYTHON_VERSION}" == "default" ]]; then PYTHON_SPECIFIER="python"; fi && \
    # Install the packages
    ./bin/micromamba install \
        --root-prefix="${CONDA_DIR}" \
        --prefix="${CONDA_DIR}" \
        --yes \
        "${PYTHON_SPECIFIER}" \
        'mamba' \
        'jupyter_core' && \
    rm -rf /tmp/bin/ && \
    # Pin major.minor version of python
    # https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-pkgs.html#preventing-packages-from-updating-pinning
    mamba list --full-name 'python' | tail -1 | tr -s ' ' | cut -d ' ' -f 1,2 | sed 's/\.[^.]*$/.*/' >> "${CONDA_DIR}/conda-meta/pinned" && \
    mamba clean --all -f -y && \
    rm -rf "/home/${NB_USER}/.cache/yarn" 


# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
RUN mamba install --quiet --yes \
    'notebook' \
    'jupyterhub' \
    'jupyterlab' \
    'nodejs=20.*' && \
    mamba clean --all -f -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    jupyter lab clean && \
    clean-layer 


# Install all OS dependencies for fully functional notebook server
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common useful utilities
    git \
    nano-tiny \
    tzdata \
    unzip \
    vim-tiny \
    # Inkscape is installed to be able to convert SVG files
    inkscape \
    # git-over-ssh
    openssh-client \
    # less is needed to run help in R
    # see: https://github.com/jupyter/docker-stacks/issues/1588
    less \
    # nbconvert dependencies
    # https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic && \
    clean-layer

# Create alternative for nano -> nano-tiny
RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    # for matplotlib anim
    ffmpeg && \
    clean-layer


RUN \ 
    mamba install --quiet --yes \
        'altair' \
        'astropy' \
        'beautifulsoup4' \
        'bokeh' \
        'bottleneck' \
        'bqplot' \
        'cartopy' \
        'cloudpickle' \
        'cmake' \
        'cython' \
        'dask-geopandas' \
        'dask-labextension' \
        'dask-sql' \
        'dask' \
        'dill' \
        'entwine' \
        'eoreader' \
        'evidently' \
        'fiona' \
        'gdal' \
        'geopandas' \
        'h5netcdf' \
        'h5py' \
        'ipycytoscape' \
        'ipyleaflet'  \
        'ipyleaflet' \
        'ipympl' \
        'ipympl'\
        'ipyparallel' \
        'ipywidgets' \
        'isce2' \
        'isce3' \
        'jupyter-lsp-python' \
        'jupyter-lsp-r' \
        'jupyter-lsp' \
        'jupyterhub' \
        'jupyterlab_code_formatter' \
        'jupyterlab-drawio' \
        'jupyterlab-git' \
        'jupyterlab-lsp' \
        'jupyterlab-system-monitor' \
        'jupyterlab' \
        'jupytext' \
        'leafmap' \
        'matplotlib-base' \
        'nbclient' \
        'nbdime' \
        'nbformat' \
        'nbqa' \
        'netcdf4' \
        'nikola' \
        'notebook' \
        'numba' \
        'numexpr' \
        'pandas-profiling' \
        'pandas' \
        'panel' \
        'patsy' \
        'pdal' \
        'pdal' \
        'protobuf' \
        'pygmt' \
        'pyproj' \
        'pyroSAR' \
        'pytables' \
        'python-lsp-server' \
        'python-pdal' \
        'pythreejs' \
        'r-languageserver' \
        'rasterio' \
        'richdem' \
        'rioxarray' \
        'scikit-image' \
        'scikit-learn' \
        'scipy' \
        'seaborn' \
        'shapely' \
        'sqlalchemy' \
        'statsmodels' \
        'sympy' \
        'voila' \
        'widgetsnbextension'\
        'xarray' \
        'xlrd' \
        'zarr' \
  && \
    clean-layer


RUN \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    pip install --no-cache-dir jupyterlab-novnc jupyterlab-mathjax3 jupyterlab-geojson jupyterlab-katex jupyterlab-fasta jupyterlab-latex && \
    # jupyter lab build -y --dev-build=False --minimize=False && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    clean-layer

# RUN \
#     jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
#     lab_ext_install='jupyter labextension install --no-build '  && \
#     lab_ext_build='jupyter lab build '  && \
#     # Also activate ipywidgets extension for JupyterLab
#     # Check this URL for most recent compatibilities
#     # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
#     eval $lab_ext_install \
#         jupyter-matplotlib \
#         @jupyter-widgets/jupyterlab-manager \
#         @bokeh/jupyter_bokeh \
#         @jupyterlab/debugger \
#         plotlywidget \
#         dask-labextension \
#         jupyterlab-chart-editor \
#         @jupyterlab/translation \
#         @jupyterlab/translation-extension \
#         @jupyterlab/hdf5 \
#         @jupyterlab/geojson-extension \
#         @jupyterlab/latex \
#         @jupyterlab/fasta-extension \
#         @jupyterlab/geojson-extension \
#         @jupyterlab/katex-extension \
#         @jupyterlab/mathjax3-extension \
#         @jupyterlab/plugin-playground && \
#     # jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
#     # jupyter labextension install @bokeh/jupyter_bokeh --no-build && \
#     # jupyter labextension install jupyter-matplotlib --no-build && \
#     # jupyter lab build -y && \
#     # jupyter lab clean -y && \
#     eval $lab_ext_build && \
#     jupyter lab clean && \
#     npm cache clean --force && \
#     clean-layer


# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets 

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="${HOME}/.cache/"

RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" 


# # Install pysarpro
# RUN pip install --quiet --no-cache-dir \
#     pysarpro  




WORKDIR /projects
ENV HOME=/projects


#RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc

ADD notebooks /projects/
ADD rootfs/root /root/
ADD maap-jupyter-ide/entrypoint.sh /maap-jupyter-ide/entrypoint.sh
# Overwrite & add Labels
LABEL \
    "maintainer"="me@imansour.net" \
    "author"="Islam Mansour" 

####### MAAP Setup

# Install all OS dependencies for fully functional notebook server
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common useful utilities
    s3fs && \
    clean-layer


#RUN pip install --global-option=build_ext --global-option="-I/usr/include/gdal" GDAL==`gdal-config --version` && \

# We add the script folder and the zip file to be able to unzip the structure of the project
COPY maap-jupyter-ide/scripts/initTemplate.sh /usr/bmap/initTemplate.sh
COPY maap-jupyter-ide/scripts/initCredentials.sh /usr/bmap/initCredentials.sh
COPY maap-jupyter-ide/scripts/Project_template.zip /usr/bmap/Project_template.zip
COPY maap-jupyter-ide/scripts/shareAlgorithm.sh /usr/bmap/shareAlgorithm.sh
COPY maap-jupyter-ide/scripts/.gitlab-ci.yml /usr/bmap/.gitlab-ci.yml
COPY maap-jupyter-ide/scripts/.condarc /usr/bmap/.condarc

# We add the RestClient file
COPY maap-jupyter-ide/scripts/RestClient.py /usr/bmap/RestClient.py
COPY maap-jupyter-ide/scripts/quicklook_raster.py /usr/bmap/quicklook_raster.py
COPY maap-jupyter-ide/scripts/ingestData.py /usr/bmap/ingestData.py
COPY maap-jupyter-ide/scripts/ingestData.sh /usr/bmap/ingestData.sh
COPY maap-jupyter-ide/scripts/maap-s3.py /usr/bmap/maap-s3.py
COPY maap-jupyter-ide/scripts/installLib.sh /usr/bmap/.installLib.sh

RUN chmod a+rwx -R /usr/bmap/

RUN  chmod +x /usr/bmap/initTemplate.sh
RUN  chmod +x /usr/bmap/shareAlgorithm.sh
RUN  chmod +x /usr/bmap/ingestData.sh
RUN  chmod +x /usr/bmap/maap-s3.py

ENV PATH="/usr/bmap/:${PATH}"
ENV PYTHONPATH="/usr/bmap/:${PYTHONPATH}"
ENV PATH="/usr/modules/:${PATH}"
ENV PYTHONPATH="/usr/modules/:${PYTHONPATH}"

#################################
# END OF ESA CUSTOMISATION
#################################


RUN mkdir /.jupyter


    

RUN export PATH="/usr/bmap/:$PATH"
RUN echo "PATH=/opt/conda/bin:${PATH}:/usr/bmap/" >> /etc/environment

RUN chmod a+rwx -R /maap-jupyter-ide/ && chmod a+rwx -R /.jupyter

ENV SHELL="bash"

WORKDIR /projects
EXPOSE 3100

ENTRYPOINT ["/bin/bash", "/maap-jupyter-ide/entrypoint.sh"]

# Julia installation
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)
# Check https://julialang.org/downloads/
ARG julia_version="1.7.2"

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Julia dependencies
# install Julia packages in /opt/julia instead of ${HOME}
ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia \
    JULIA_VERSION="${julia_version}"

WORKDIR /tmp

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=SC2046
RUN set -x && \
    julia_arch=$(uname -m) && \
    julia_short_arch="${julia_arch}" && \
    if [ "${julia_short_arch}" == "x86_64" ]; then \
      julia_short_arch="x64"; \
    fi; \
    julia_installer="julia-${JULIA_VERSION}-linux-${julia_arch}.tar.gz" && \
    julia_major_minor=$(echo "${JULIA_VERSION}" | cut -d. -f 1,2) && \
    mkdir "/opt/julia-${JULIA_VERSION}" && \
    wget -q "https://julialang-s3.julialang.org/bin/linux/${julia_short_arch}/${julia_major_minor}/${julia_installer}" && \
    tar xzf "${julia_installer}" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
    rm "${julia_installer}" && \
    ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"${CONDA_DIR}/lib\")" >> /etc/julia/juliarc.jl
    
# R packages including IRKernel which gets installed globally.
RUN mamba install --quiet --yes \
    'r-base' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-nycflights13' \
    'r-randomforest' \
    'r-rcurl' \
    'r-rmarkdown' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidyverse' \
    'rpy2' \
    'unixodbc' \
    'r-terra' \
    'r-rgdal' \
    && clean-layer

# R Pacakges
RUN R -e 'install.packages("raster", repos="https://rspatial.r-universe.dev")' \
    && R -e 'install.packages("fields", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("ncdf4", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("lubridate", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("raster", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("dplyr", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("ggplot2", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("tidyverse", repos="http://cran.us.r-project.org")' \
    && R -e 'install.packages("randomForest", repos="http://cran.us.r-project.org")'\
    && R -e 'install.packages("caret", repos="http://cran.us.r-project.org")'\
    && R -e 'install.packages("reshape2", repos="http://cran.us.r-project.org")'\
    && R -e 'install.packages("rgdal", repos="http://cran.us.r-project.org")' \
    && R -e 'pck<-c("tidyr","raster","ggplot2","randomForest", "caret", "reshape2", "rgdal")' \
    && clean-layer



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
