FROM nginx:1.21.6

RUN mkdir www
WORKDIR /www

COPY /dist ./

RUN rm /etc/nginx/nginx.conf
RUN ln -s /etc/nginx/pod-profiler-frontend/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
