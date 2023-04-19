FROM node:16-alpine as frontend-builder
WORKDIR /front
COPY ./frontend/package.json ./
RUN npm install
COPY ./frontend/ ./
RUN npm run build

FROM python:3.10-alpine3.16 as backend
WORKDIR /app
COPY ./backend/requirements.txt /app
RUN pip3 install -r requirements.txt
COPY ./backend/ ./
RUN python3 manage.py collectstatic --noinput

FROM nginx:latest as frontend 
WORKDIR /var/www/django
COPY ./nginx.conf /etc/nginx/
RUN rm /etc/nginx/conf.d/default.conf
COPY --from=frontend-builder /front/dist ./dist
COPY --from=backend /app/static/admin ./static/admin
CMD ["nginx", "-g", "daemon off;"]

