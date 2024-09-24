FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install -r requirements.txt

ENV LAMBDA_TASK_ROOT=/var/task
ENV HF_HOME=/tmp

COPY src/* ${LAMBDA_TASK_ROOT}

CMD [ "lambda_function.handler" ]