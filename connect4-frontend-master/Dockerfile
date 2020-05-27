FROM python:3.7
WORKDIR /
COPY requirements.txt /
RUN pip3 install -r ./requirements.txt
ADD . /
CMD python3 Server.py