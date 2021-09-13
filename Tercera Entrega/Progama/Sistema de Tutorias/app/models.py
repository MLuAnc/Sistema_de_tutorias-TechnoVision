from django.contrib.auth.models import AbstractUser
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver

class Semestre(models.Model):
    SEMESTRES = (
        ('I','Primer Semestre'),
        ('II','Segundo Semestre')
    )
    id = models.AutoField(primary_key=True)
    anio = models.IntegerField("Año")
    semestre = models.CharField("Semestre", choices=SEMESTRES, max_length = 30)
    objects = models.Manager()

    def __str__(self):
        return str(self.anio) + "-" + self.semestre


# Overriding the Default Django Auth User and adding One More Field (user_type)
class CustomUser(AbstractUser):
    user_type_data = ((1, "COORDINADOR"), (2, "TUTOR"), (3, "ESTUDIANTE"))
    user_type = models.CharField(default=1, choices=user_type_data, max_length=20)


class Coordinador(models.Model):
    id = models.AutoField(primary_key=True)
    admin = models.OneToOneField(CustomUser, on_delete = models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()


class Tutor(models.Model):
    id = models.AutoField(primary_key=True)
    admin = models.OneToOneField(CustomUser, on_delete = models.CASCADE)
    address = models.CharField("Direccion", max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()


class Estudiante(models.Model):
    SEXO_EST = (
        ('VARON', 'VARON'),
        ('MUJER', 'MUJER'),
    )
    id = models.AutoField(primary_key=True)
    admin = models.OneToOneField(CustomUser, on_delete = models.CASCADE)
    gender = models.CharField(max_length=50, choices= SEXO_EST)
    profile_pic = models.FileField()
    address = models.TextField()
    session_year_id = models.ForeignKey(Semestre, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    objects = models.Manager()


#Creating Django Signals

# It's like trigger in database. It will run only when Data is Added in CustomUser model

@receiver(post_save, sender=CustomUser)
# Now Creating a Function which will automatically insert data in HOD, Staff or Student
def create_user_profile(sender, instance, created, **kwargs):
    # if Created is true (Means Data Inserted)
    if created:
        # Check the user_type and insert the data in respective tables
        if instance.user_type == 1:
            Coordinador.objects.create(admin=instance)
        if instance.user_type == 2:
            Tutor.objects.create(admin=instance)
        if instance.user_type == 3:
            Estudiante.objects.create(admin=instance, session_year_id=Semestre.objects.get(id=1), address="", profile_pic="", gender="")
    

@receiver(post_save, sender=CustomUser)
def save_user_profile(sender, instance, **kwargs):
    if instance.user_type == 1:
        instance.coordinador.save()
    if instance.user_type == 2:
        instance.tutor.save()
    if instance.user_type == 3:
        instance.estudiante.save()
    


