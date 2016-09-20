from flask import render_template, flash, redirect, request
from app import app
from forms import LoginForm,SaltWebForm
from setting import account
import logging,datetime
from logging.handlers import RotatingFileHandler
from saltapi import SaltClient
import gc

@app.route('/')
@app.route('/index')
def index():
    return render_template('index.html', title = 'Home')

@app.route('/login', methods = ['GET', 'POST'])
def login():
	form = LoginForm()
	if request.method == 'POST' and form.validate_on_submit():
		if account.get(form.username.data) == form.password.data:
			flash("login success")
			return redirect('/saltweb')
		else:
			flash("Please enter correct username and password")
			return redirect('/login')

	return render_template('login.html', form = form,title = 'login')

@app.route('/logout', methods = ['GET', 'POST'])
def logout():
	flash('logout success')
	return "logout success"

@app.route('/saltweb', methods = ['GET', 'POST'])
def saltweb():
	form = SaltWebForm()
	if request.method == 'POST' and form.validate_on_submit():
		saltclient = SaltClient(form.serverId.data)
		flash(saltclient.GetServerInfo())
		app.logger.info(saltclient.GetServerInfo())
		logStr = ""
		if form.serverStart.data:
			saltclient.ServerStart()
			logStr = "server id:" + form.serverId.data +" start"
		elif form.serverClose.data:
			saltclient.ServerClose()
			logStr = "server id:" + form.serverId.data +" close"
		elif form.serverTimeModify.data:
			timeStr = str(form.serverTime.data.year) + "-" + str(form.serverTime.data.month) + "-" + str(form.serverTime.data.day)
			saltclient.ServerTimeMod(timeStr)
			logStr = "server id:" + form.serverId.data +" time:" + timeStr
		elif form.serverInfo.data:
			logStr = saltclient.ServerInfo()
		elif form.serverLog.data:
			logStr = saltclient.ServerLog()
		elif form.serverCheck.data:
			logStr = saltclient.ServerCheck()

		flash(logStr)
		app.logger.info(logStr)
		del saltclient
		gc.collect()
		return redirect('/saltweb')
	return render_template('saltweb.html', form = form,title = 'saltweb')

