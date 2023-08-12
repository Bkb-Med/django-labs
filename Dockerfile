# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.9-alpine3.13

USER root

EXPOSE 8000 3000

# Keeps Python from generating .pyc files in the container
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1


RUN apk --update upgrade && \
    apk add sqlite && \
    rm -rf /var/cache/apk/* 
# See http://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY ./app /app
RUN chmod 755 /app/app
# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app  
USER appuser


# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi"]
