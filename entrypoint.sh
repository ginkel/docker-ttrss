#!/bin/sh
php /configure-db.php && exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
