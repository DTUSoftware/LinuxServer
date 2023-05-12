FROM python

WORKDIR /app
COPY requirements.txt /app
RUN python -m pip install -r requirements.txt

COPY . /app

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
