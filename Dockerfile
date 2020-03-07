FROM linuxserver/nzbget:arm32v7-latest

COPY qemu-arm-static /usr/bin/qemu-arm-static
LABEL maintainer="duendeazul"


VOLUME /scripts
VOLUME /var/log/sickbeard_mp4_automator/


# Install Git
RUN apk add --no-cache git

# Install MP4 Automator
RUN git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git /scripts/mp4_automator

# create logging directory
# RUN mkdir /var/log/sickbeard_mp4_automator && \
 RUN touch /var/log/sickbeard_mp4_automator/index.log && \
  chgrp -R users /var/log/sickbeard_mp4_automator && \
  chmod -R g+w /var/log/sickbeard_mp4_automator

RUN apk add --no-cache \
  py-setuptools \
  py-pip \
  python-dev \
  libffi-dev \
  gcc \
  musl-dev \
  openssl-dev \
  ffmpeg
RUN pip install --upgrade PIP
RUN pip install requests
RUN pip install requests[security]
RUN pip install requests-cache
RUN pip install babelfish
RUN pip install guessit
RUN pip install subliminal
RUN pip install qtfaststart
RUN pip install mutagen
RUN pip install tmdbsimple
RUN pip install stevedore
RUN pip install python-dateutil

# As per https://github.com/mdhiggins/sickbeard_mp4_automator/issues/643
ONBUILD RUN pip uninstall stevedore
ONBUILD RUN pip install stevedore==1.19.1

#Set MP4_Automator script settings in NZBGet settings
RUN echo 'NZBGetPostProcess.py:MP4_FOLDER=/scripts/MP4_Automator' >> /config/nzbget.conf
RUN echo 'NZBGetPostProcess.py:SHOULDCONVERT=True' >> /config/nzbget.conf

#Set script and log file permissions
RUN chmod 777 -R /scripts
RUN chmod 777 -R /var/log/sickbeard_mp4_automator/

#Set script directory setting in NZBGet
#RUN /app/nzbget -o ScriptDir=/app/scripts,${MP4Automator_dir},/scripts/nzbToMedia
#ONBUILD RUN sed -i 's/^ScriptDir=.*/ScriptDir=\/app\/scripts;\/scripts\/MP4_Automator;\/scripts\/nzbToMedia/' /config/nzbget.conf

VOLUME ["/scripts/mp4_automator/autoProcess.ini"]
