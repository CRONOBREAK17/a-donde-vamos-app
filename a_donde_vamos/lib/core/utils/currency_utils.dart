// lib/core/utils/currency_utils.dart
import 'dart:io';
import 'package:intl/intl.dart';

class CurrencyUtils {
  // Precio base en USD
  static const double basePriceUSD = 1.67; // $30 MXN ≈ $1.67 USD

  /// Obtener información de moneda basada en el locale del dispositivo
  static Map<String, dynamic> getCurrencyInfo() {
    // Obtener locale del sistema
    final locale = Platform.localeName; // ej: "es_MX", "en_US", "es_AR"
    final countryCode = locale.split('_').length > 1
        ? locale.split('_')[1]
        : 'US';

    // Tasas de conversión aproximadas (puedes usar una API para valores en tiempo real)
    final Map<String, Map<String, dynamic>> currencies = {
      'MX': {
        'symbol': '\$',
        'name': 'MXN',
        'rate': 18.0,
        'decimals': 0,
      }, // Peso Mexicano
      'US': {
        'symbol': '\$',
        'name': 'USD',
        'rate': 1.0,
        'decimals': 2,
      }, // Dólar
      'AR': {
        'symbol': '\$',
        'name': 'ARS',
        'rate': 350.0,
        'decimals': 0,
      }, // Peso Argentino
      'CL': {
        'symbol': '\$',
        'name': 'CLP',
        'rate': 900.0,
        'decimals': 0,
      }, // Peso Chileno
      'CO': {
        'symbol': '\$',
        'name': 'COP',
        'rate': 4000.0,
        'decimals': 0,
      }, // Peso Colombiano
      'PE': {
        'symbol': 'S/',
        'name': 'PEN',
        'rate': 3.7,
        'decimals': 2,
      }, // Sol Peruano
      'ES': {'symbol': '€', 'name': 'EUR', 'rate': 0.92, 'decimals': 2}, // Euro
      'GB': {
        'symbol': '£',
        'name': 'GBP',
        'rate': 0.79,
        'decimals': 2,
      }, // Libra
      'BR': {
        'symbol': 'R\$',
        'name': 'BRL',
        'rate': 5.0,
        'decimals': 2,
      }, // Real Brasileño
      'VE': {
        'symbol': 'Bs',
        'name': 'VES',
        'rate': 36.0,
        'decimals': 2,
      }, // Bolívar
    };

    // Obtener moneda del país o usar USD por defecto
    final currencyData = currencies[countryCode] ?? currencies['US']!;
    final rate = currencyData['rate'] as double;
    final price = basePriceUSD * rate;

    return {
      'symbol': currencyData['symbol'],
      'code': currencyData['name'],
      'price': price,
      'decimals': currencyData['decimals'],
      'countryCode': countryCode,
    };
  }

  /// Formatear precio según la moneda
  static String formatPrice(Map<String, dynamic> currencyInfo) {
    final price = currencyInfo['price'] as double;
    final decimals = currencyInfo['decimals'] as int;
    final symbol = currencyInfo['symbol'] as String;
    final code = currencyInfo['code'] as String;

    if (decimals == 0) {
      // Sin decimales (pesos mexicanos, argentinos, chilenos, etc)
      return '$symbol${price.round()} $code';
    } else {
      // Con decimales (USD, EUR, etc)
      return '$symbol${price.toStringAsFixed(decimals)} $code';
    }
  }

  /// Obtener texto completo del precio
  static String getPriceText() {
    final info = getCurrencyInfo();
    return formatPrice(info);
  }

  /// Obtener símbolo de moneda
  static String getCurrencySymbol() {
    final info = getCurrencyInfo();
    return info['symbol'] as String;
  }

  /// Obtener código de moneda
  static String getCurrencyCode() {
    final info = getCurrencyInfo();
    return info['code'] as String;
  }
}
