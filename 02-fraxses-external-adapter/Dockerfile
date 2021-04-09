FROM python:alpine3.7
#COPY . /app
RUN mkdir /app
COPY requirements.txt /app
COPY Pipfile /app
COPY Pipfile.lock /app
WORKDIR /app
RUN pip3 install pipenv
RUN pipenv install --system --deploy --ignore-pipfile
RUN pip3 install python-dotenv
COPY . /app
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]
