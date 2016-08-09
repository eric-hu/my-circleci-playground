FROM phusion/passenger-customizable:0.9.18

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Customize the image, build system and git, apt-get update
RUN /pd_build/utilities.sh
RUN /pd_build/ruby2.2.sh
RUN /pd_build/python.sh
RUN apt-get -y install python-pip
RUN /pd_build/nodejs.sh

# Create app directory
RUN mkdir -p /opt/monitoring
# the copies fail in CircleCI, see https://discuss.circleci.com/t/failed-docker-build-at-a-copy-step-in-dockerfile/5440
COPY requirements.txt /opt/monitoring
COPY package.json /opt/monitoring
COPY Gemfile /opt/monitoring
WORKDIR /opt/monitoring

# Install dependencies & other support tooling
RUN bundle install
RUN pip install -r requirements.txt
RUN npm install

COPY . /opt/monitoring

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*