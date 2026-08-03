# app.conf is used by keyd-application-mapper.
#
# All the others are used by keyd itself.

# So to install:
#
ln -s "$PWD"/*.conf /etc/keyd/
rmlink /etc/keyd/app.conf
