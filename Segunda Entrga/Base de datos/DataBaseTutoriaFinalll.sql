/* ********************************************************************
					    CREACIÓN DE LA BASE DE DATOS
   ******************************************************************** */
use master
go
IF EXISTS (SELECT * 
				FROM SYSDATABASES
				WHERE NAME = 'BDSistema_Tutoria')
	DROP DATABASE BDSistema_Tutoria
GO

CREATE DATABASE BDSistema_Tutoria
GO


USE BDSistema_Tutoria
go

/************** TABLA ESCUELA_PROFESIONAL **************/
--CREATE TABLE TEscuela_Profesional
--(
--	CodEP char(2) primary key not null,
--	NombreEP varchar(80) not null
--);

/************** TABLA USUARIOS **************/
create table TUsuarios
( --lista de atributos
  loginName		nvarchar(100) primary key NOT NULL,
  Password		nvarchar(100) unique  not null,
  --TipoUsuario	varchar(50) not null
)

/********************* TABLA DOCENTE ******************/
create table TDocente
(
	CodDocente varchar(7) primary key not null,
	Nombre varchar(50) not null,
	ApPaterno varchar(50) not null,
	ApMaterno varchar(50) not null,
	Clase varchar(30), check (Clase = 'NOMBRADO'and  Clase = 'CONTRATADO'),
	DepAcademico varchar(80) not null,
	Facultad varchar(100) not null,
	--ID y Contraseña
	LoginDocente nvarchar(100) foreign key (LoginDocente) references TUsuarios(loginName) not null,
	ContrDocente nvarchar(100) foreign key (ContrDocente) references TUsuarios(Password) not null
)


/********************* TABLA ESTUDIANTE ***************/
create table TEstudiante
(
	CodEstudiante varchar(6) primary key not null,
	Nombres varchar(50) not null,
	ApPaterno varchar(50) not null,
	ApMaterno varchar(50) not null,
	--EP char(2) foreign key (EP) references TEscuela_Profesional(CodEP) not null,
	EP varchar(20),
	Email varchar(50),
	Direccion varchar(80),
	--ID y Contraseña
	LoginEstudiante nvarchar(100) foreign key (LoginEstudiante) references TUsuarios(loginName) not null,
	ContrEstudiante nvarchar(100) foreign key (ContrEstudiante) references TUsuarios(Password) not null
)

/******************** TABLA COORDINADOR TUTORIA*************/
create table TCoordinadorTutoria
(
	CodCoordTutoria varchar(7) primary key not null,
	foreign key (CodCoordTutoria) references TDocente(CodDocente),
	GradoAcademico varchar(50) not null,
	NroOficina varchar(10)
)


/******************* TABLA TUTOR ACADEMICO *****************/
CREATE TABLE TTutorAcademico
(
	CodTutor varchar(7) primary key not null,
	foreign key (CodTutor) references TDocente(CodDocente),
	Turno varchar(20) not null,
	HorasTutoria int not null,
)

/***************** TABLA DECANO DE FACULTAD ****************/
CREATE TABLE TDecanoFacultad
(
	CodDecano varchar(7) primary key not null,
	foreign key (CodDecano) references TDocente(CodDocente),
	NroOficina varchar(10) not null,
)

/**************** TABLA ESTUDIANTE EN RIESGO **************/
CREATE TABLE TEstudianteRiesgo
(
	CodEstudiante varchar(6) primary key not null,
	foreign key (CodEstudiante) references TEstudiante(CodEstudiante),
	CursoDesaprobado int not null,
	EstadoAcademico varchar(15) not null,
	NroVecesDesaprobado int not null
)

/*************** TABLA ESTUDIANTE AYUDANTE ******************/
CREATE TABLE TEstudianteAyudante
(
	CodEstudiante varchar(6) primary key not null,
	foreign key (CodEstudiante) references TEstudiante(CodEstudiante)
)

/***************** TABLA TALLERES REFORZAMIENTO **************/
CREATE TABLE TTalleresReforzamiento
(
	CodTaller varchar(6) primary key not null,
	TipoTaller varchar(50) not null,
	Fecha datetime not null,
	CodEstudianteAyudante varchar(6) not null,
	CodEstudiante varchar(6) not null,
	CreditosExtraCurr int not null,
	foreign key (CodEstudianteAyudante) references TEstudianteAyudante(CodEstudiante),
	foreign key (CodEstudiante) references TEstudianteRiesgo(CodEstudiante)
)


/****************** TABLA CONTROL DE ASISTENCIA**************/
create table TControlAsistencia_Taller
(
	NroControlAsistencia int identity primary key not null,
	CodTaller varchar(6) not null,
	CodEstudiante varchar(6) not null,
	Observaciones varchar(80),
	foreign key (CodTaller) references TTalleresReforzamiento(CodTaller)
)


/********************** TABLA REPORTE ASISTENCIA **************/
CREATE TABLE TReporteAsistencia
(
	CodReporte varchar(6) primary key not null,
	CodEstudAyudante varchar(6) not null,
	Fecha datetime,
	CodEstudianteEnRiesgo varchar(6) not null,
	Obervaciones varchar(80)
	foreign key (CodEstudAyudante) references TEstudianteAyudante(CodEstudiante)
)

/************************ TABLA TUTORIA ***********************/
CREATE TABLE TTutoria
(
	CodTutoria varchar(6) primary key not null,
	Fecha datetime not null,
	SemestreAcademico varchar(8) not null,
	CodTutor varchar(7) not null,
	CodEstudiante varchar(6) not null,
	foreign key (CodTutor) references TTutorAcademico(CodTutor),
	foreign key (CodEstudiante) references TEstudianteRiesgo(CodEstudiante)
)

/**************** TABLA DETALLE_CONCURSO***********************/

CREATE TABLE TDetalleConcurso
(
	CodConcurso varchar(6) primary key not null,
	Fecha datetime not null,
	NroCupos int not null,
	Lugar varchar(80) not null,
	Responsable varchar(50) not null,
	Estado varchar(50) not null
)

/*************** TABLA CONCURSO ESTUDIANTE AYUDANTE**********/
CREATE TABLE TConcursoEstudianteAyudante
(
	CodConcurso varchar(6) not null,
	CodDecano varchar(7) not null,
	CodParticipante varchar(6) not null,
	primary key (CodConcurso, CodDecano, CodParticipante),
	foreign key (CodDecano) references TDecanoFacultad(CodDecano),
	foreign key (CodParticipante) references TEstudianteAyudante(CodEstudiante),
	foreign key (CodConcurso) references TDetalleConcurso(CodConcurso)
)
-- drop table TConcursoEstudianteAyudante


/***************** TABLA CRONOGRAMA **************************/
CREATE TABLE TCronograma
(
	CodCronograma varchar(6) primary key not null,
	Fecha datetime not null,
	Lugar varchar(50) not null,
	Hora varchar(10) not null,
	CodDocente varchar(7) not null,
	foreign key (CodDocente) references TCoordinadorTutoria(CodCoordTutoria)
)


/******************* TABLA INFORME ACTIVIDADES ***************/
CREATE TABLE TInformeActividades
(
	CodInformeAct varchar(6) primary key not null,
	Fecha datetime not null,
	CodTutor varchar(7) not null,
	CodCoordTutoria varchar(7) not null,
	foreign key (CodTutor) references  TTutorAcademico(Codtutor),
	foreign key (CodCoordTutoria) references TCoordinadorTutoria(CodCoordtutoria)
)


/************** TABLA INFORME ESTUDIANTE RIESGO ***********/
CREATE TABLE TInfomeEstudianteRiesgo
(
	CodInformeRiesgo varchar(6) primary key not null,
	CodTutor varchar(7) not null,
	CodEstudiante varchar(6) not null,
	Fecha datetime,
	foreign key (CodTutor) references TTutorAcademico(CodTutor),
)


/*************** TABLA CONTROL ASISTENCIA TUTORIA ************/
CREATE TABLE TControlAsistencia_Tutoria
(
	NroControlAsistencia int  primary key identity not null,
	CodTutoria varchar(6) not null,
	CodEstudiante varchar(6) not null,
	Observaciones varchar(80) not null,
	foreign key (CodTutoria) references TTutoria(CodTutoria)
)