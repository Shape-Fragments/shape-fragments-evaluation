FROM python:latest
ADD tyrol/ /shape-views-validation/tyrol/
ARG TOKEN
RUN pip3 install pyshacl
RUN git clone https://github.com/Shape-Fragments/pySHACL-fragments.git
RUN git clone https://github.com/Shape-Fragments/pySHACL-timers.git
ADD measure_times.sh /shape-views-validation/
CMD cd shape-views-validation && ./measure_times.sh
