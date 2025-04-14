from rest_framework import serializers
from .models import PregnancyJournal

class PregnancyJournalSerializer(serializers.ModelSerializer):
    class Meta:
        model = PregnancyJournal
        fields = '__all__'
        read_only_fields = ['user','id','date']
