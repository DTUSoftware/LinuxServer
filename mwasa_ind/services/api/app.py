from flask import Flask

app = Flask(__name__)

@app.route('/api/launchCode')
def launch_code():
	return {
        "launchCode": "Pa55word!"
    }

if __name__ == '__main__':
	app.run(host='0.0.0.0')
