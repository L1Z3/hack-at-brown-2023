import os
import requests
import pickle
from typing import List, Dict, Tuple
import openai
from outscraper import ApiClient
from flask import Flask, redirect, render_template, request, session, url_for, jsonify
from transformers import GPT2TokenizerFast

tokenizer = GPT2TokenizerFast.from_pretrained("gpt2")

app = Flask(__name__)

with open("secret.txt", "r") as f:
    app.secret_key = f.read()

with open("openai-key.txt", "r") as f:
    openai.api_key = f.read()

with open("places-key.txt") as f:
    places_api_key = f.read()

with open("outscraper-api-key.txt") as f:
    outscraper_api_key = f.read()

with open("password.txt") as f:
    password = f.read()


# memo dict outside of memoizer! this is bad! i dont care!

if os.path.exists("cache.pickle"):
    with open("cache.pickle", "rb") as f:
        memo = pickle.load(f)
else:
    memo = {}

def memoize(function):

    def wrapper(*args):
        if args in memo:
            return memo[args]
        else:
            rv = function(*args)
            memo[args] = rv
            with open("cache.pickle", "wb") as f:
                pickle.dump(memo, f)
            return rv

    return wrapper


client = ApiClient(api_key=outscraper_api_key)


# TODO what if we made it summarize sets of about 5 or 10 reviews and then had it answer the question based on the summary

# TODO slider on the frontend that specifies number of reviews to look at?

@memoize
def get_reviews_api(place: str, number_of_reviews: int = 5) -> Tuple:
    results = client.google_maps_reviews(place, reviews_limit=number_of_reviews, limit=1, language='en')
    print(results)
    if len(results) == 0 or "reviews_data" not in results[0]:
        raise ConnectionError("There was an error fetching data!")
    # print(results[0]["photo"])
    # print(results[0]["description"])
    # print(results[0].keys())
    reviews_data = results[0]["reviews_data"]
    reviews_str_list = []
    for review in reviews_data:
        reviews_str_list.append(review["review_text"])
    # TODO also encode review score?
    return results[0]["name"], reviews_str_list, results[0]["full_address"], results[0]["phone"], results[0][
        "description"], results[0]["rating"], results[0]["photo"]


@memoize
def get_place_info_api(place_id: str) -> Tuple:
    url = f'https://maps.googleapis.com/maps/api/place/details/json?place_id={place_id}&fields=name,formatted_address,formatted_phone_number,formatted_phone_number,rating,user_ratings_total,review,editorial_summary,photos&key={places_api_key}'
    # Send the GET request to the Places API
    response = requests.get(url)
    # Get the JSON data from the response
    data = response.json()["result"]
    # print(data)
    reviews_str_list = []
    if "reviews" in data:
        for review in data["reviews"]:
            reviews_str_list.append(review["text"])
    description, address, number, rating, photo_id = "None", "None", "None", "None", "None"
    if "editorial_summary" in data:
        description = data["editorial_summary"]["overview"]
    if "formatted_address" in data:
        address = data["formatted_address"]
    if "formatted_phone_number" in data:
        number = data["formatted_phone_number"]
    if "rating" in data:
        rating = data["rating"]
    if "photos" in data:
        if len(data["photos"]) > 0:
            photo_id = data["photos"][0]["photo_reference"]
    

    return data["name"], reviews_str_list, address, number, description, rating, photo_id


def get_gpt3_response(input_text: str, max_tokens: int) -> str:
    response = openai.Completion.create(
        model="text-davinci-003",
        prompt=input_text,
        max_tokens=max_tokens,
        temperature=0.7,
    )
    if "choices" not in response or len(response["choices"]) == 0 or "text" not in response["choices"][0]:
        # uh this is bad practice! i don't care!
        return "I'm sorry, we encountered an error. Please try again later."
    print(response["choices"][0]["text"].strip())
    return response["choices"][0]["text"].strip()


def generate_summary_prompt(place_name: str, reviews: List[str]) -> str:
    output_tokens = 250
    input_max_tokens = 4000 - output_tokens - 20
    prompt = f"Below are a variety of reviews for a place called \"{place_name}\". \n\n"
    num_used = 0
    for review in reviews:
        new_prompt = prompt + "Here is a review:\n" + review
        if get_num_tokens(new_prompt) > input_max_tokens:
            break
        prompt = new_prompt + "\n\n"
        num_used += 1
    prompt = prompt + "\n\n" + "Now, generate a useful summary of the given reviews for a person looking to go to this place."
    print(prompt)
    print(f"-----------Used {num_used} reviews in about prompt.-----------")
    return prompt


def generate_question_prompt(place_name: str, reviews: List[str], question: str):
    output_tokens = 250
    input_max_tokens = 4000 - output_tokens - 30 - get_num_tokens(question)
    prompt = f"Below are a variety of reviews for a place called \"{place_name}\". \n\n"
    num_used = 0
    for review in reviews:
        new_prompt = prompt + "Here is a review:\n" + review
        if get_num_tokens(new_prompt) > input_max_tokens:
            break
        prompt = new_prompt + "\n\n"
        num_used += 1
    prompt = prompt + "\n\n" + f"Now, based on the reviews, generate a useful answer to the following question from a person looking to attend this place: \n\"{question}\""
    print(prompt)
    print(f"-----------Used {num_used} reviews in about prompt.-----------")
    return prompt


def get_num_tokens(prompt: str) -> int:
    return len(tokenizer(prompt)['input_ids'])


num_reviews = 10

"""
example in:
{
    "place_id": "ChIJpy7YpHF_44kRZ0CG8kUMwn8",
    "password": "..."
}
"""
@app.route('/get_place_info', methods=['POST'])
def get_place_info():
    data = request.get_json()
    if "password" not in data or data["password"] != password:
        return jsonify({"error": "wrong password!!!"})
    if "place_id" not in data:
        return jsonify({"error": "place_id not in request!!!!"})
    place_id = data["place_id"]
    # num_reviews = 5
    # if num_reviews <= 5:
    name, reviews, address, phone, description, rating, photo = get_place_info_api(place_id)
    # else:
    #     name, reviews, address, phone, description, rating, photo = get_reviews_api(place_id, num_reviews)
    # TODO also send reviews so you can view source reviews
    response = {
        "name": name,
        "address": address,
        "phone": phone,
        "description": description,
        "rating": rating,
        "photo": photo
    }
    return jsonify(response)

"""
example in:
{
    "place_id": "ChIJpy7YpHF_44kRZ0CG8kUMwn8",
    "max_reviews": 5,
    "password": "..."
}
"""
@app.route('/get_summary', methods=['POST'])
def get_summary():
    data = request.get_json()
    if "password" not in data or data["password"] != password:
        return jsonify({"error": "wrong password!!!"})
    if "place_id" not in data:
        return jsonify({"error": "place_id not in request!!!!"})
    place_id = data["place_id"]
    if "max_reviews" in data and type(data["max_reviews"]) is int:
        cur_num_reviews = data["max_reviews"]
    else:
        cur_num_reviews = num_reviews
    # num_reviews = 5
    if cur_num_reviews <= 5:
        name, reviews, _, _, _, _, _ = get_place_info_api(place_id)
    else:
        name, reviews, _, _, _, _, _ = get_reviews_api(place_id, cur_num_reviews)
    if len(reviews) == 0:
        gpt_summary = "I'm sorry. This place has no reviews."
    else:
        # TODO also send reviews so you can view source reviews
        prompt = generate_summary_prompt(name, reviews)
        gpt_summary = get_gpt3_response(prompt, 250)
    response = {
        "summary": gpt_summary,
    }
    return jsonify(response)

"""
example in:
{
    "place_id": "ChIJpy7YpHF_44kRZ0CG8kUMwn8",
    "question": "Are they nice?",
    "max_reviews": 5,
    "password": "..."
}
"""
@app.route('/ask_question', methods=['POST'])
def ask_question():
    data = request.get_json()
    if "password" not in data or data["password"] != password:
        return jsonify({"error": "wrong password!!!"})
    if "place_id" not in data or "question" not in data:
        return jsonify({"error": "place_id or question not in request!!!!"})
    place_id = data["place_id"]
    question = data["question"]
    if "max_reviews" in data and type(data["max_reviews"]) is int:
        cur_num_reviews = data["max_reviews"]
    else:
        cur_num_reviews = num_reviews
    # num_reviews = 5
    if cur_num_reviews <= 5:
        name, reviews, _, _, _, _, _ = get_place_info_api(place_id)
    else:
        name, reviews, _, _, _, _, _ = get_reviews_api(place_id, cur_num_reviews)
    if len(reviews) == 0:
        gpt_answer = "I'm sorry. This place has no reviews."
    else:
        prompt = generate_question_prompt(name, reviews, question)
        gpt_answer = get_gpt3_response(prompt, 250)
    response = {
        "answer": gpt_answer
    }
    return jsonify(response)


# if __name__ == '__main__':
#     app.run()
    # print(get_place_info_api("ChIJKY6zkCRF5IkRyyCi9_xpfgs"))
    # print(get_gpt3_response("Hi, how's it going?", 250))
    # print(get_reviews_api("ChIJQdr1UryyQYgRaUnFwsH2AOs"))
    # data = get_reviews_api("ChIJpy7YpHF_44kRZ0CG8kUMwn8", 1)
    # prompt = generate_summary_prompt(data["name"], data["reviews"])
    # print(prompt)
    # print("\n\n")
    # print(get_gpt3_response(prompt, 250))

if __name__ == "__main__":
    from waitress import serve
    serve(app, host="0.0.0.0", port=25565)
