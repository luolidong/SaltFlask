import salt.client
from app import app
import logging
from logging.handlers import RotatingFileHandler
from setting import SERVER_NUM

class SaltClient:

	def __init__(self,serverId):
		self.serverId = serverId
		self.local = salt.client.LocalClient()
		self.serverInfos = []

		ret = self.local.cmd("*","cmd.run",["bash /data/control.sh 1-" + str(SERVER_NUM) + " s conf-server_id &"])
		for key in ret.keys():
			i = 1 
			for serverIdConf in ret.get(key).split('\n'):
				if serverIdConf.split('=')[1] == serverId:
					self.serverInfos.append((key,str(i)))
				i = i + 1

	def ServerStart(self):
		for info in self.serverInfos:
			self.local.cmd_async(info[0],"cmd.run",["bash /data/control.sh " + info[1] + " s start &"],timeout = 1)
		
	def ServerClose(self):
		for info in self.serverInfos:
			self.local.cmd_async(info[0],"cmd.run",["bash /data/control.sh " + info[1] + " s kill &"])

	def ServerTimeMod(self,timeStr):
		for info in self.serverInfos:
			self.local.cmd_async(info[0],"cmd.run",["bash /data/control.sh " + info[1] + " m " + timeStr + " &"])

	def ServerInfo(self):
		ret = []
		for info in self.serverInfos:
			result = self.local.cmd(info[0],"cmd.run",["bash /data/control.sh " + info[1] + " s info &"])
			for key in result.keys():
				result[key] = result.get(key).replace('\n', ' ')
			ret.append(result)
				
		return ret

	def GetServerInfo(self):
		return self.serverInfos

	def ServerLog(self):
		ret = []
		for info in self.serverInfos:
			result = self.local.cmd(info[0],"cmd.run",["bash /data/control.sh " + info[1] + " s msg &"])
			for key in result.keys():
				result[key] = result.get(key).replace('\n', ' | ')
			ret.append(result)
				
		return ret

	def ServerCheck(self):
		ret = []
		for info in self.serverInfos:
			result = self.local.cmd(info[0],"cmd.run",["ps -ef | grep hqg | grep -v grep"])
			for key in result.keys():
				result[key] = result.get(key).replace('\n', ' | ')
			ret.append(result)
				
		return ret


#client = SaltClient('100')
#client.ServerStart()
#client.ServerClose()
