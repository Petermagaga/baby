# Generated by Django 5.1.2 on 2025-03-06 11:20

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
            name='Baby',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('date_of_birth', models.DateField()),
                ('weight_at_birth', models.FloatField(help_text='Weight in kg')),
                ('parent', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='babies', to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='ImmunizationRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('vaccine_name', models.CharField(max_length=255)),
                ('scheduled_date', models.DateField()),
                ('status', models.CharField(choices=[('pending', 'Pending'), ('completed', 'Completed')], default='pending', max_length=10)),
                ('baby', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='immunizations', to='baby_tracking.baby')),
            ],
        ),
    ]
