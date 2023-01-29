# Calcifer.ai - Virtual Travel Assistant
## Hack @ Brown 2023 Submission
Project for Hack at Brown 2023.
### Inspiration
If you've ever been to a restaurant or public establishment of any sort, you might know how hard it is to have your questions answered before actually going to that place. How's the food? How clean is the place? How friendly are the staff? All of these things are good to know beforehand, but searching through Yelp, Google, and other websites for reviews can be a pain especially when you're looking to get something specific answered.

### What it does
Inspired by Calcifer from Howl's Moving Castle who is the de facto "travel director" of the castle, Calcifer.ai makes travelling to establishments easy by scraping the internet for existing knowledge of any establishment that you're thinking of visiting and answers any questions you might have about the place without your having to leave the comfort of your couch. You can search up places nearby (or far, but it will prioritize places nearby), and look at details, or ask Calcifer some questions!

### How we built it
We used natural language processing in combination with a number of different APIs and webscraping tools.

## Running
Run `pip install -r requirements.txt` in the backend folder to install the requirements. In the backend folder, five files are needed:
* `password.txt`, containing a password for authentication.
* `openai-key.txt`, containing your GPT-3 API key
* `outscaper-api-key.txt`, containing your API key for Outscraper
* `places-key.txt`, containing your API key for the Google Places API
* `secret.txt`, containing a secret for Flask to use

In the frontend, make a file in the `lib` folder called `secret.dart`, with the following contents:
```javascript
const GOOGLE_PLACES_API_KEY = "<YOUR GOOGLE PLACES API KEY>";
const FLASK_PASSWORD = "<YOUR PASSWORD FROM password.txt>";
```

Also, in `utilities/network.dart` on the frontend, replace every instance of `http://cs300.eastus2.cloudapp.azure.com:25565` with the URL for the backend.

Then simply run the Flask backend, compile the Flutter frontend, and have fun!