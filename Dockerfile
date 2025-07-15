# Builder stage: use Hugging Face image and run script to download models
FROM huggingface/downloader:0.17.3 AS download

ARG HF_TOKEN
ENV HF_TOKEN=${HF_TOKEN:-}
ENV HF_HOME=/opt/hf-cache
ENV TRANSFORMERS_CACHE=/opt/hf-cache

# Copy and run the download script
COPY download_models.sh /tmp/download_models.sh
RUN apk add bash && /tmp/download_models.sh

# Runtime stage: image + baked cache
FROM python:3.10-slim

# ---- gcloud SDK (unchanged) ----
RUN apt-get update && apt-get install -y curl gnupg dnsutils \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && apt-get update && apt-get install -y google-cloud-sdk \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# copy models 
COPY --from=download /opt/hf-cache /opt/hf-cache

WORKDIR /app

# Copy and install requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY main.py .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


ENV HF_HOME=/opt/hf-cache
ENV TRANSFORMERS_CACHE=/opt/hf-cache
# Force transformers to use the local cache
ENV TRANSFORMERS_OFFLINE=1

# Expose the port the app runs on
EXPOSE 8000
ENTRYPOINT ["/entrypoint.sh"]
