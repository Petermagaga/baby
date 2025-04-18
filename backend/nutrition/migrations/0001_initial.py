# Generated by Django 5.1.7 on 2025-03-07 05:26

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='NutritionGuide',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('trimester', models.IntegerField(choices=[(1, 'First Trimester'), (2, 'Second Trimester'), (3, 'Third Trimester')])),
                ('common_symptoms', models.TextField(help_text='Symptoms like nausea, fatigue')),
                ('recommended_foods', models.TextField(help_text='Foods beneficial for this stage')),
                ('foods_to_avoid', models.TextField(help_text='Harmful foods for this stage')),
                ('key_nutrients', models.TextField(help_text='Nutrients needed at this stage')),
            ],
        ),
        migrations.CreateModel(
            name='DailyMealPlan',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.DateField(auto_now_add=True)),
                ('breakfast', models.TextField(help_text='Breakfast meal plan')),
                ('lunch', models.TextField(help_text='Lunch meal plan')),
                ('dinner', models.TextField(help_text='Dinner meal plan')),
                ('snacks', models.TextField(help_text='Recommended snacks')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='meal_plans', to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
