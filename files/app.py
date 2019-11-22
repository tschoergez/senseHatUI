from flask import Flask, render_template, redirect, request, url_for, jsonify, session
from flask_assets import Bundle, Environment
import requests
from base64 import b64encode
from sense_hat import SenseHat
from colorzero import Color

app = Flask(__name__, static_url_path='', static_folder='static')
app.secret_key = "super secret key"

env = Environment(app)
js = Bundle('js/clarity-icons.min.js', 'js/clarity-icons-api.js',
            'js/clarity-icons-element.js', 'js/custom-elements.min.js')
env.register('js_all', js)
css = Bundle('css/clarity-ui.min.css', 'css/clarity-icons.min.css')
env.register('css_all', css)
sense = SenseHat()
sense.set_rotation(180)

@app.route('/', methods=["GET"])
def index():
    return redirect(url_for('colors'))

@app.route('/login', methods=["GET", "POST"])
def homepage():
    if request.method == "POST": 
        attempted_username = request.form['message']
        print(attempted_username)
        sense.show_message(attempted_username, text_colour=[255,255,255])
        return redirect(url_for('homepage'))
    return render_template('index.html')

@app.route('/colors')
def colors():
    return render_template('colors.html')

@app.route('/workflows')
def workflows():
    sensedata = {}
    sensedata['temperature'] = sense.get_pressure()
    sensedata['humidity'] = sense.get_humidity()	
    return render_template('workflows.html', flows=[sensedata])

@app.route('/api/rgb/<rgb>', methods=['GET'])
def clear_led_color(rgb):
    c = Color('#'+rgb)
    sense.clear(c.rgb_bytes)
    return jsonify({"success":True})


@app.route('/api/led/<rgb>', methods=['GET'])
def set_led_color(rgb):
    if rgb == 'red':
        X = [255, 0, 0]  # Red
    elif rgb == 'green':
        X = [0, 255, 0]  # green
    elif rgb == 'blue':
        X = [0, 0, 255]  # blue
    color = [
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X,
        X, X, X, X, X, X, X, X
        ]
    sense.set_pixels(color)
    return redirect(url_for('colors'))

@app.route('/api/write', methods=['POST'])
def set_message():
    if not request.json or not 'message' in request.json:
        abort(400)
    sense.show_message(request.json["message"], text_colour=[255,255,255])
    return jsonify({'success': True})


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
