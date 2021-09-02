FROM python:latest
ADD tyrol/ /shape-views-validation/tyrol/
ARG TOKEN
RUN pip3 install pyshacl
RUN git clone https://tdlva:$TOKEN@gitlab.ilabt.imec.be/KNoWS/projects/d2ai/shape-views/pyshacl-views.git/
RUN git clone https://tdlva:$TOKEN@gitlab.ilabt.imec.be/KNoWS/projects/d2ai/shape-views/pySHACL-timers.git/
ADD measure_times.sh /shape-views-validation/
CMD cd shape-views-validation && ./measure_times.sh
