#!flask/bin/python
from app import app
import logging
from logging.handlers import RotatingFileHandler,SysLogHandler

if __name__ == '__main__':
	handler = RotatingFileHandler('log/foo.log',maxBytes=10000,backupCount=1)
	handler.setLevel(logging.INFO)
	formatter = logging.Formatter('%(asctime)s - %(message)s')
	handler.setFormatter(formatter)
	app.logger.addHandler(handler)
	app.run(host='0.0.0.0')
