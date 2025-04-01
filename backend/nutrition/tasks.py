from celery import shared_task
from django.contrib.auth import get_user_model
from .models import DailyMealPlan

User=get_user_model()




from datetime import date

def get_pregnancy_stage(user):
    """Determines pregnancy stage based on user's profile."""
    profile = user.profile  # Assuming user has a profile with pregnancy data

    if not profile or not profile.due_date:
        return "Unknown"  # Return if data is missing

    today = date.today()
    days_pregnant = (profile.due_date - today).days

    if days_pregnant > 196:  # 28+ weeks
        return "Third Trimester"
    elif days_pregnant > 98:  # 14-27 weeks
        return "Second Trimester"
    elif days_pregnant > 0:  # 1-13 weeks
        return "First Trimester"
    else:
        return "Postpartum"  # After due date

from celery import shared_task
from django.contrib.auth import get_user_model
from .models import DailyMealPlan

User = get_user_model()

@shared_task
def generate_daily_meal_plan():
    users = User.objects.all()  # Get all users

    for user in users:
        pregnancy_stage = get_pregnancy_stage(user)  # Function to determine pregnancy stage
        conditions = user.profile.health_conditions.split(",") if user.profile.health_conditions else []

        meal_plan = {
            "breakfast": "Oatmeal with bananas and nuts",
            "lunch": "Grilled chicken with brown rice and steamed veggies",
            "dinner": "Salmon with quinoa and avocado salad",
            "snacks": "Greek yogurt with honey"
        }

        if "Diabetes" in conditions:
            meal_plan["breakfast"] = "Whole wheat toast with avocado"
            meal_plan["snacks"] = "Almonds and sugar-free yogurt"

        if "Anemia" in conditions:
            meal_plan["lunch"] = "Spinach salad with lean beef"
            meal_plan["snacks"] = "Dried apricots and orange juice"

        DailyMealPlan.objects.create(
            user=user,
            breakfast=meal_plan["breakfast"],
            lunch=meal_plan["lunch"],
            dinner=meal_plan["dinner"],
            snacks=meal_plan["snacks"]
        )

    return f"Meal plans generated for {users.count()} users"
