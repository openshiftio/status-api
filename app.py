from flask import Flask
from flask_restful import Resource, Api
from func import *
from ast import literal_eval

app = Flask(__name__)
api = Api(app)

hostgroups ={}
hostgroups_env = environ['HOSTGROUPS']
hostgroups_split = hostgroups_env.split(";")
for hg in hostgroups_split:
	value = hg.split(":")
	hostgroups[value[0]] = literal_eval(value[1])

class Show_Status(Resource):
	def get(self):
		stat = {}
		for x in hostgroups.keys():
			stat[x] = check_stat(hostgroups[x])
		return {"status": stat }

@app.route("/")
def main():
	return "Welcome"
	
api.add_resource(Show_Status, '/status')

if __name__ == '__main__':
    app.run( host='0.0.0.0', port=8080, debug=False)
