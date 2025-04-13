from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import UserProfile


class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = UserProfile
        fields = [
            'username',
            'email',
            'password',
            'age',
            'health_conditions',
            'location',
            'job_type',
            'profile_picture',
        ]
        extra_kwargs = {
            'email': {'required': True},
        }

    def validate_email(self, value):
        if UserProfile.objects.filter(email=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value

    def create(self, validated_data):
        user = UserProfile(
            username=validated_data['username'],
            email=validated_data['email'],
            age=validated_data.get('age'),
            health_conditions=validated_data.get('health_conditions', ''),
            location=validated_data.get('location', ''),
            job_type=validated_data.get('job_type', ''),
            profile_picture=validated_data.get('profile_picture', None),
        )
        user.set_password(validated_data['password'])
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')

        if username and password:
            user = authenticate(username=username, password=password)
            if not user:
                raise serializers.ValidationError("Invalid username or password.")
            if not user.is_active:
                raise serializers.ValidationError("This account is inactive.")
        else:
            raise serializers.ValidationError("Both username and password are required.")

        data['user'] = user
        return data


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id',
            'username',
            'email',
            'age',
            'health_conditions',
            'location',
            'job_type',
            'profile_picture',
        ]


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'username',
            'email',
            'age',
            'health_conditions',
            'location',
            'job_type',
            'profile_picture',
        ]
        read_only_fields = ['email']  