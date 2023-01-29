// Search Page
const searchSub = "Search for any establishment and ask questions based on "
    "previous reviews.";
const searchHint = 'Where are you going?';

// Location Info Page
const locationNoDesc = "No description available";
const locationFailedLoad = "Failed to load";
const locationNoPhone = "No phone number available";

//FAQ
const askHint = "What would you like to know?";
const askSendTooltip = "Ask me!";
const askUnableToRetrieve = "Hmm...I'm sorry, but I wasn't able to think straight.";
String initialMessage(title) {
  return "Hello! Feel free to ask me anything about $title and I'll hopefully be"
      "able to answer!";
}