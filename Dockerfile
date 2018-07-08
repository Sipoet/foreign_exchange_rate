# Use an official Python runtime as a parent image
FROM ruby:2.5

# Install any needed packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory to /app
RUN mkdir /myapp
WORKDIR /myapp

# Copy the current directory contents into the container at /app
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# Install any needed library in gemfile
RUN bundle install

COPY . /myapp

# Make port 80 available to the world outside this container
EXPOSE 3000

# Define environment variable
ENV NAME World

# Run rails framework when the container launches
# CMD "rails db:create && rails db:migrate"
