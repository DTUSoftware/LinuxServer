FROM python

WORKDIR /app
COPY requirements.txt /app
RUN python -m pip install -r requirements.txt --proxy 192.168.154.1:3128

COPY . /app

EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["app.py"]
