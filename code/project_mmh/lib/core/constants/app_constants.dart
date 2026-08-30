// Constantes de dominio compartidas. Fuente única para límites y valores por
// defecto que antes estaban duplicados (a veces con valores divergentes) en
// varias pantallas.

/// Máximo de sesiones por tratamiento (1 inicial + adicionales).
const int kMaxSesionesPorTratamiento = 12;

/// Duración por defecto de una sesión al crearla.
const Duration kDuracionSesionDefault = Duration(hours: 1);

/// Longitud máxima del nombre de un tratamiento.
const int kMaxNombreTratamiento = 40;

/// Longitud máxima del nombre de un periodo académico.
const int kMaxNombrePeriodo = 40;

/// Longitud máxima de nombre / apellidos de un paciente.
const int kMaxNombrePaciente = 40;

/// Longitud máxima del número de expediente.
const int kMaxIdExpediente = 15;

/// Edad mínima / máxima admitida para un paciente (alineado con el CHECK de BD).
const int kEdadMinPaciente = 0;
const int kEdadMaxPaciente = 120;
