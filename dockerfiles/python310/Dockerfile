
FROM python:3.10-slim-bullseye

# Set environment variables.
ENV PYTHONWRITEBYTECODE 1
ENV PYTHONBUFFERED 1

# Set working directory.
WORKDIR /mnt

# Copy dependencies.
COPY requirements.txt /mnt/

# Install dependencies.
# install dependencies
RUN apt-get update && \
    apt-get install -y \
    gcc \
    musl-dev \
    libpq-dev && \
    pip install -r requirements.txt

# Copy project.
COPY . /mnt/

EXPOSE 5000

ENTRYPOINT [ "gunicorn", "app.main:app", "--workers", "2", "--worker-class", \
        "uvicorn.workers.UvicornWorker",  "-b", "0.0.0.0:5000" ]
