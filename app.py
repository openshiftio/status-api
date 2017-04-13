from flask import Flask, request
from flask_restful import Resource, Api

app = Flask(__name__)
api = Api(app)

class Show_Status(Resource):
	def get(self):
		stat = {
			"A" : "green",
			"B" : "green",
			"C" : "green",
			"D" : "green"
			}
		return {"status": stat }


@app.route("/")
def main():
	return "Welcome"
	
api.add_resource(Show_Status, '/status')

if __name__ == '__main__':
    app.run( host='0.0.0.0', port=8080, debug=False)
