from rest_framework import generics, permissions
from django.conf import settings
from .serializers import ChatbotMessageSerializer
from .models import ChatbotMessage
import google.generativeai as genai

# Configure Google Gemini API
genai.configure(api_key=settings.GEMINI_API_KEY)
gemini_model = genai.GenerativeModel("gemini-pro")


class ChatbotView(generics.CreateAPIView):
    serializer_class = ChatbotMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        user_message = serializer.validated_data['message']
        ai_response = call_gemini_model(user_message)  # Use Gemini for AI response
        serializer.save(user=self.request.user, response=ai_response)


def call_gemini_model(user_message):
    """Generates a response using Google's Gemini AI model."""
    try:
        response = gemini_model.generate_content(user_message)
        if response and response.candidates:
            return response.candidates[0].content.parts[0].text.strip()
        return "Sorry, I couldn't generate a response."
    except Exception as e:
        return f"Error generating response: {str(e)}"
