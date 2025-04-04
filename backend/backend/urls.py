from django.conf import settings
from django.contrib import admin
from django.conf.urls.static import static

from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('users.urls')),
    path('api/tracker/', include('tracker.urls')),
    path("api/chat/", include("chat.urls")),
 
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path("api/baby_tracking/", include("baby_tracking.urls")),
    path('api/nutrition/',include("nutrition.urls")),
    path('api/',include("faq.urls")),
    path('api/emergency/',include("emergency.urls")),
    path('api/health_insights/',include("health_insights.urls")),
    path('api/chatbot/',include('chatbot.urls')),
    path('api/journal/',include('journal.urls')),
    path('api/mental_health/',include('mental_health.urls')),
    path('api/friends/',include('friends.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

