from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import NutritionAdvice
from .serializers import NutritionAdviceSerializer

class BabyNutritionAdviceView(APIView):
    def get(self, request):
        # Get the 'weight' query parameter
        weight = request.query_params.get('weight')

        # If the weight parameter is missing
        if not weight:
            return Response({"error": "Weight parameter is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Try to convert the weight to a float
        try:
            weight = float(weight)  # Use float to allow for decimal values
        except ValueError:
            return Response({"error": "Invalid weight parameter."}, status=status.HTTP_400_BAD_REQUEST)

        # Query the NutritionAdvice model for the given weight
        advice = NutritionAdvice.objects.filter(weight=weight)

        if advice.exists():
            # Serialize the data and return the response
            serializer = NutritionAdviceSerializer(advice, many=True)
            return Response(serializer.data)
        else:
            return Response({"error": "No advice found for this weight."}, status=status.HTTP_404_NOT_FOUND)
