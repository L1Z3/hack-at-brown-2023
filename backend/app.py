import os
import requests
from typing import List, Dict, Tuple
import openai
from outscraper import ApiClient
from flask import Flask, redirect, render_template, request, session, url_for, jsonify
from transformers import GPT2TokenizerFast

tokenizer = GPT2TokenizerFast.from_pretrained("gpt2") \
 \
app = Flask(__name__)

with open("secret.txt", "r") as f:
    app.secret_key = f.read()

with open("openai-key.txt", "r") as f:
    openai.api_key = f.read()

with open("places-key.txt") as f:
    places_api_key = f.read()

with open("outscraper-api-key.txt") as f:
    outscraper_api_key = f.read()


def memoize(function):
    memo = {}

    def wrapper(*args):
        if args in memo:
            return memo[args]
        else:
            rv = function(*args)
            memo[args] = rv
            return rv

    return wrapper


client = ApiClient(api_key=outscraper_api_key)


# TODO what if we made it summarize sets of about 5 or 10 reviews and then had it answer the question based on the summary

# TODO what if we had two search options: normal and deep? deep gives more reviews to work with

# TODO slider on the frontend that specifies number of reviews to look at?

def get_reviews_api(place: str, number_of_reviews: int = 5) -> Tuple:
    # TODO will it make it faster to only return the needed fields?
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
    # TODO cache reviews
    # TODO also encode review score?
    return results[0]["name"], reviews_str_list, results[0]["full_address"], results[0]["phone"], results[0][
        "description"], results[0]["rating"], results[0]["photo"]


def get_place_info_api(place_id: str) -> Tuple:
    url = f'https://maps.googleapis.com/maps/api/place/details/json?place_id={place_id}&fields=name,formatted_address,formatted_phone_number,formatted_phone_number,rating,user_ratings_total,review,editorial_summary&key={places_api_key}'
    # Send the GET request to the Places API
    response = requests.get(url)
    # Get the JSON data from the response
    data = response.json()["result"]
    reviews_str_list = []
    for review in data["reviews"]:
        reviews_str_list.append(review["text"])
    # TODO parse response
    return data["name"], reviews_str_list, data["formatted_address"], data["formatted_phone_number"], "None", data[
        "rating"], "None"


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
    for review in reviews:
        new_prompt = prompt + "Here is a review:\n" + review
        if get_num_tokens(new_prompt) > input_max_tokens:
            break
        prompt = new_prompt + "\n\n"
    prompt = prompt + "\n\n" + "Now, generate a useful summary of the given reviews for a person looking to go to this place."
    print(prompt)
    return prompt


def generate_question_prompt(place_name: str, reviews: List[str], question: str):
    output_tokens = 250
    input_max_tokens = 4000 - output_tokens - 30 - get_num_tokens(question)
    prompt = f"Below are a variety of reviews for a place called \"{place_name}\". \n\n"
    for review in reviews:
        new_prompt = prompt + "Here is a review:\n" + review
        if get_num_tokens(new_prompt) > input_max_tokens:
            break
        prompt = new_prompt + "\n\n"
    prompt = prompt + "\n\n" + f"Now, based on the reviews, generate a useful answer to the following question from a person looking to attend this place: \n\"{question}\""
    print(prompt)
    return prompt


def get_num_tokens(prompt: str) -> int:
    return len(tokenizer(prompt)['input_ids'])


num_reviews = 20

"""
example in:
{
    "place_id": "ChIJpy7YpHF_44kRZ0CG8kUMwn8"
}

error: 
{
    "error": "..."
}
"""


@app.route('/get_place_info', methods=['POST'])
def get_place_info():
    data = request.get_json()
    if "place_id" not in data:
        return jsonify({"error": "place_id not in request!!!!"})
    place_id = data["place_id"]
    # num_reviews = 5
    if num_reviews <= 5:
        name, reviews, address, phone, description, rating, photo = get_place_info_api(place_id)
    else:
        name, reviews, address, phone, description, rating, photo = get_reviews_api(place_id, num_reviews)
    # TODO separately send data and gpt response
    # TODO also send reviews so you can view source reviews
    prompt = generate_summary_prompt(name, reviews)
    gpt_summary = get_gpt3_response(prompt, 250)
    response = {
        "name": name,
        "summary": gpt_summary,
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
    "question": "Are they nice?"
}

error: 
{
    "error": "..."
}
"""


@app.route('/ask_question', methods=['POST'])
def ask_question():
    data = request.get_json()
    if "place_id" not in data or "question" not in data:
        return jsonify({"error": "place_id or question not in request!!!!"})
    place_id = data["place_id"]
    question = data["question"]
    # num_reviews = 5
    if num_reviews <= 5:
        name, reviews, _, _, _, _, _ = get_place_info_api(place_id)
    else:
        name, reviews, _, _, _, _, _ = get_reviews_api(place_id, num_reviews)
    prompt = generate_question_prompt(name, reviews, question)
    gpt_answer = get_gpt3_response(prompt, 250)
    response = {
        "answer": gpt_answer
    }
    return jsonify(response)


if __name__ == '__main__':
    app.run()
    # print(get_place_info_api("ChIJw4LLjb5MQIgR-ZmtAqdA7jE"))
    # print(get_gpt3_response("Hi, how's it going?", 250))
    # print(get_reviews_api("ChIJpy7YpHF_44kRZ0CG8kUMwn8"))
    # data = get_reviews_api("ChIJpy7YpHF_44kRZ0CG8kUMwn8", 1)
    # prompt = generate_summary_prompt(data["name"], data["reviews"])
    # print(prompt)
    # print("\n\n")
    # print(get_gpt3_response(prompt, 250))
