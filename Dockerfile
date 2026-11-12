FROM python:3.11-slim

COPY app /app
# Build deps are needed to compile uvloop (via litestar[standard]) on armv7 when no
# prebuilt wheel is available. They are purged in the same layer to keep the image small.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential autoconf automake libtool pkg-config \
 && python -m pip install /app --extra-index-url https://www.piwheels.org/simple \
 && apt-get purge -y build-essential autoconf automake libtool pkg-config \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 8000/tcp

LABEL version="0.0.5-infin.1"

LABEL permissions='\
{\
  "ExposedPorts": {\
    "8000/tcp": {}\
  },\
  "HostConfig": {\
    "Binds":["/usr/blueos/extensions/ntrip-to-mavlink/config:/app/config"],\
    "ExtraHosts": ["host.docker.internal:host-gateway"],\
    "PortBindings": {\
      "8000/tcp": [\
        {\
          "HostPort": ""\
        }\
      ]\
    }\
  }\
}'

LABEL authors='[\
    {\
        "name": "Willian Galvani",\
        "email": "willian@bluerobotics.com"\
    }\
]'

LABEL company='{\
        "about": "",\
        "name": "Blue Robotics",\
        "email": "support@bluerobotics.com"\
    }'
LABEL type="other"
LABEL readme='https://raw.githubusercontent.com/williangalvani/BlueOS-Ntrip-extension/{tag}/README.md'
LABEL links='{\
        "source": "https://github.com/williangalvani/BlueOS-Ntrip-extension"\
    }'
LABEL requirements="core >= 1.1"

WORKDIR /app
ENTRYPOINT ["python", "main.py", "--host", "0.0.0.0", "--config-file", "config/rtk_config.json"]
