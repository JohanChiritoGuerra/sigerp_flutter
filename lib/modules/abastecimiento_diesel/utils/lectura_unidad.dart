import 'package:flutter/material.dart';

// Formatea kilometraje/horómetro para mostrar en tarjetas y detalles — un
// abastecimiento puede tener uno, el otro, o ambos (ver Km/Horómetro en
// AbastecimientoDieselRepository), así que nunca se asume cuál viene.
// Devuelve null si no hay ninguno de los dos (no debería pasar en la
// práctica, el backend exige al menos uno, pero es un caso defensivo).
String? lecturaUnidad(int? kilometraje, double? horometro) {
  final partes = <String>[
    if (kilometraje != null) '${_conSeparadorMiles(kilometraje)} km',
    if (horometro != null) '${horometro.toStringAsFixed(1)} h',
  ];
  if (partes.isEmpty) return null;
  return partes.join(' · ');
}

// Mismo ícono que su switch correspondiente en el formulario (Icons.speed_outlined
// para Kilometraje, Icons.timelapse_outlined para Horómetro) — si hay ambos,
// se prioriza el de Kilometraje ya que va primero en el texto combinado.
IconData? lecturaIcono(int? kilometraje, double? horometro) {
  if (kilometraje != null) return Icons.speed_outlined;
  if (horometro != null) return Icons.timelapse_outlined;
  return null;
}

// Una entrada (ícono, texto) por cada lectura presente — para cuando hace
// falta mostrarlas en líneas separadas (tarjetas de listado) en vez de
// combinadas en un solo texto con "·" (lecturaUnidad/lecturaIcono).
List<(IconData, String)> lecturaEntradas(int? kilometraje, double? horometro) {
  return [
    if (kilometraje != null) (Icons.speed_outlined, '${_conSeparadorMiles(kilometraje)} km'),
    if (horometro != null) (Icons.timelapse_outlined, '${horometro.toStringAsFixed(1)} h'),
  ];
}

String _conSeparadorMiles(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  final offset = texto.length % 3;
  for (var i = 0; i < texto.length; i++) {
    if (i != 0 && (i - offset) % 3 == 0) buffer.write(',');
    buffer.write(texto[i]);
  }
  return buffer.toString();
}
