FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
RUN useradd --create-home --shell /bin/bash orderhub
USER orderhub
ENV APP_Version=1.0.0
ENV PORT=8080
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  cmd python -c "import urllib.reuest; urllib.request.urlopen('http://localhost:8080/health')"
CMD [ "python","app/app.py" ]