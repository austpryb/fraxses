FROM python:3.8

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

RUN apt-get update -y && apt-get update \
  && apt-get install -y --no-install-recommends curl gcc g++ gnupg unixodbc-dev

RUN apt-get update && apt-get install -y libssl-dev

RUN apt-get update && apt-get install -y npm

RUN npm install -g ganache-cli

RUN npm install @openzeppelin/contracts

COPY requirements.txt .
COPY requirements-fraxses.txt .
COPY python_fraxses_wrapper-0.4.0-py3-none-any.whl .

RUN pip install -r requirements.txt
RUN pip install -r requirements-fraxses.txt
RUN pip install python_fraxses_wrapper-0.4.0-py3-none-any.whl

RUN pip install eth-brownie

#COPY dapps/chainlink /usr/src/app
COPY dapps/hackathon /usr/src/app

#VOLUME /usr/src/app dapps/chainlink 

# CMD ["brownie", "bake", "chainlink-mix"]

# CMD ["brownie", "compile"]

# WORKDIR /code

CMD ["python", "/usr/src/app/app/app.py"]
