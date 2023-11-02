FROM python:3.9.7-alpine3.14

LABEL elasticsearch-curator=5.8.1

# Variables de entorno
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8

# Instalación de paquetes
RUN set -eux; \
    apk add --no-cache ca-certificates tzdata;

# Variables de entorno
ENV GPG_KEY=E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION=3.9.7

# Descarga, verificación, y compilación de Python
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps gnupg tar xz \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY" \
    && gpg --batch --verify python.tar.xz.asc python.tar.xz \
    && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
    && rm -rf "$GNUPGHOME" python.tar.xz.asc \
    && mkdir -p /usr/src/python \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    && apk add --no-cache --virtual .build-deps bluez-dev bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev linux-headers make ncurses-dev openssl-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev util-linux-dev xz-dev zlib-dev \
    && apk del --no-network .fetch-deps \
    && cd /usr/src/python \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-optimizations --enable-option-checking=fatal --enable-shared --with-system-expat --with-system-ffi --without-ensurepip \
    && make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" LDFLAGS="-Wl,--strip-all" \
    && make install \
    && rm -rf /usr/src/python \
    && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \) -exec rm -rf '{}' + \
    && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' | xargs -rt apk add --no-cache --virtual .python-rundeps \
    && apk del --no-network .build-deps \
    && python3 --version

# Creando enlaces simbólicos para ejecutables de Python (accesos directos)
RUN cd /usr/local/bin 
#\
    #&& ln -s idle3 idle \
    #&& ln -s pydoc3 pydoc \
    #&& ln -s python3 python \
    #&& ln -s python3-config python-config

# Variables de entorno
ENV PYTHON_PIP_VERSION=21.2.4
ENV PYTHON_SETUPTOOLS_VERSION=57.5.0
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/3cb8888cc2869620f57d5d2da64da38f516078c7/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256=c518250e91a70d7b20cceb15272209a4ded2a0c263ae5776f129e0d9b5674309

# Instalando Pip
RUN set -ex; \
    wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
    echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
    python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" "setuptools==$PYTHON_SETUPTOOLS_VERSION" ; \
    pip --version; \
    find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +; \
    rm -f get-pip.py

# Cambiando el comando por defecto al iniciar el contenedor
CMD ["python3"]

# Añadiendo una etiqueta al contenedor
LABEL elasticsearch-curator=5.8.4

# Dado que PyYAML en la version 5.4.1 no funciona con la version de python, descargamos la wheel y la instalamos 
# (Cuidar ese archivo COMO ORO que ya no hay version para alpine en la pagina oficial de pyyaml)
COPY PyYAML-5.4.1-cp39-cp39-linux_x86_64.whl /usr/bin/PyYAML-5.4.1-cp39-cp39-linux_x86_64.whl

RUN pip install /usr/bin/PyYAML-5.4.1-cp39-cp39-linux_x86_64.whl

# Instalando Elasticsearch Curator
RUN pip install elasticsearch-curator==5.8.4 && rm -rf /var/cache/apk/*

# Copiando el script entrypoint.sh al contenedor
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Estableciendo el entrypoint del contenedor
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
