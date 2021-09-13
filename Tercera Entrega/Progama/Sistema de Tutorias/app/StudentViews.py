from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from django.contrib import messages
from django.core.files.storage import FileSystemStorage #To upload Profile Picture
from django.urls import reverse
import datetime # To Parse input DateTime into Python Date Time Object

from app.models import *

def student_home(request):
    student_obj = Estudiante.objects.get(admin=request.user.id)
  
    context={
        "total_attendance": 0,
        "attendance_present": 0,
        "attendance_absent": 0,
        "total_subjects": 0,
        "subject_name": 0,
        "data_present": 0,
        "data_absent": 0
    }
    return render(request, "student_template/student_home_template.html", context)


def student_profile(request):
    user = CustomUser.objects.get(id=request.user.id)
    student = Estudiante.objects.get(admin=user)

    context={
        "user": user,
        "student": student
    }
    return render(request, 'student_template/student_profile.html', context)


def student_profile_update(request):
    if request.method != "POST":
        messages.error(request, "Invalid Method!")
        return redirect('student_profile')
    else:
        first_name = request.POST.get('first_name')
        last_name = request.POST.get('last_name')
        password = request.POST.get('password')
        address = request.POST.get('address')

        try:
            customuser = CustomUser.objects.get(id=request.user.id)
            customuser.first_name = first_name
            customuser.last_name = last_name
            if password != None and password != "":
                customuser.set_password(password)
            customuser.save()

            student = Estudiante.objects.get(admin=customuser.id)
            student.address = address
            student.save()
            
            messages.success(request, "Actualizado correctamente!!!")
            return redirect('student_profile')
        except:
            messages.error(request, "Error al actualizar informacion")
            return redirect('student_profile')


