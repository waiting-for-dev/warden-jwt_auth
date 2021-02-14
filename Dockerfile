FROM ruby:3.0.0
ENV APP_USER warden_jwt_auth_user
RUN useradd -ms /bin/bash $APP_USER
USER $APP_USER
WORKDIR /home/$APP_USER/app
