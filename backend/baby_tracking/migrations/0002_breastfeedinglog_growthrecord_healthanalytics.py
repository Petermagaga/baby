# Generated by Django 5.1.6 on 2025-03-06 13:15

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('baby_tracking', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='BreastfeedingLog',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.DateField(auto_now_add=True)),
                ('duration', models.IntegerField(help_text='Duration in minutes')),
                ('side', models.CharField(choices=[('left', 'Left'), ('right', 'Right'), ('both', 'Both')], max_length=10)),
                ('baby', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='breastfeeding_logs', to='baby_tracking.baby')),
            ],
        ),
        migrations.CreateModel(
            name='GrowthRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.DateField(auto_now_add=True)),
                ('weight', models.FloatField(help_text='Weight in kg')),
                ('height', models.FloatField(help_text='Height in cm')),
                ('head_circumference', models.FloatField(help_text='Head circumference in cm')),
                ('baby', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='growth_records', to='baby_tracking.baby')),
            ],
        ),
        migrations.CreateModel(
            name='HealthAnalytics',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('bmi', models.FloatField(help_text='BMI Calculation')),
                ('immunization_status', models.CharField(default='Pending', max_length=50)),
                ('baby', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='health_analytics', to='baby_tracking.baby')),
            ],
        ),
    ]
