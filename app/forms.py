from flask_wtf import Form
from wtforms import BooleanField, StringField, SubmitField,validators,DateField
from wtforms.validators import DataRequired

class LoginForm(Form):
	username = StringField('UserName:', [validators.DataRequired(),validators.Length(max=80)])
	password = StringField('PassWord',  [validators.DataRequired(),validators.Length(max=80)])
	submit = SubmitField('Sign')

class SaltWebForm(Form):
	serverId = StringField('Server Id:', [validators.DataRequired(),validators.Length(max=10)])
	serverTime = DateField('Server Time:', format='%Y-%m-%d')
	serverStart = SubmitField('start')
	serverClose = SubmitField('close')
	serverTimeModify = SubmitField('timeModify')
	serverInfo = SubmitField('info')
	serverLog = SubmitField('log')
	serverCheck = SubmitField('check process')

