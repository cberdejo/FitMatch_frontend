//const url = 'http://10.0.2.2:3000/';
import 'package:flutter/foundation.dart';

const url = kIsWeb ? 'http://localhost:3000/' : 'http://10.0.2.2:3000/';

// Authentication
const loginUrl = '${url}verificar';

// OTP
const checkOtpUrl = '${url}otp/check';
const sendOtpUrl = '${url}otp/send';

// User Management
const usuariosUrl = '${url}usuarios';
const usuarioTokenUrl = '${url}usuarioToken';
const banUserUrl = '${url}usuarios/ban';

// Plantilla (Template) Management
const plantillaPostsUrl = '${url}plantillaPosts';

//Duplicar plantilla
const duplicarPlantillaUrl = '${url}duplicatePlantilla';

//Plantilla toggle publico
const plantillaPublicoUrl = '${url}plantillaPostsPublic';

//Plantilla toggle oculto
const plantillaHiddenCreadaUrl = '${url}plantillaPostHiddenCreada';
const plantillaHiddenGuardadaUrl = '${url}plantillaPostHiddenGuardada';
const plantillaHiddenArchivadaUrl = '${url}plantillaPostHiddenArchivada';

//Guardar plantilla
const guardarPlantillaUrl = '${url}guardarPlantillaPost';

// Archivar plantilla
const archivarPlantillaUrl = '${url}archivarPlantillaPost';

// Sesión de Entrenamiento (Training Session)
const sesionEntrenamientoUrl = '${url}sesionEntrenamiento';

// Sesión de Entrenamiento (Training Session) Para obtener las sesiones de una plantilla de entrenamiento (training template)
const sesionEntrenamientoTemplateUrl = '${url}sesionEntrenamientoTemplate';

// Ejercicios (Exercises)
const ejerciciosUrl = '${url}ejercicios';

// Grupos Musculares
const grupoMuscularesUrl = '${url}grupoMuscular';
// Material
const materialUrl = '${url}material';
//Tipo de registro
const tipoRegistroUrl = '${url}tipoRegistro';
// Rutinas Guardadas (Saved Routines)
const rutinasGuardadasUrl = '${url}rutinasGuardadas';

//Rutinas Archivadas
const rutinasArchivadasUrl = '${url}rutinasArchivadas';

// Ejercicios detallados agrupados
const groupedExercisesUrl = '${url}ejerciciosDetalladosAgrupados';

//Ejercicios detallados
const exercisesDetailsUrl = '${url}ejerciciosDetallados';

// Sesión de Entrenamiento de Entrada (Training Session Entry)
const sesionEntrenamientoEntradaUrl = '${url}sesionEntrenamientoEntrada';

// Comentarios y Reviews (Comments and Reviews)
const getUsernameByClienteIdUrl = '${url}username/cliente';
const likeReviewUrl = '${url}likeReview';
const likeCommentUrl = '${url}likeComment';
const reviewsUrl = '${url}review';
const commentUrl = '${url}comment';
const commentReviewUrl = '${url}commentReview';
const commentReviewCommentUrl = '${url}commentComment';

//Registros
const registrosUrl = '${url}registros';
const registrosSessionUrl = '${url}registrosSession';
const sessionRegistrosUrl = '${url}sesionRegistros';
const registroSessionAnteriorUrl = '${url}registroSessionAnterior';
const registrosSessionPlantillaUrl = '${url}registrosSessionPlantilla';

//medidas
const medidasUrl = '${url}medidas';

//notificaciones
const notificacionUrl = '${url}notificacion';

//logs
const logsUrl = '${url}logs';

//bloqueos
const bloqueosUrl = '${url}bloqueos';
