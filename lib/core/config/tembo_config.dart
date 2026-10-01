/// Configuration for TemboPlus Payment Infrastructure
/// Documentation: https://tembo.gitbook.io/tembo
class TemboConfig {
  TemboConfig._();

  /// Environment mode
  static const bool isProduction = false;

  /// TemboPlus API Base URLs
  static const String sandboxBaseUrl = 'https://sandbox.temboplus.com/tembo/v1';
  static const String productionBaseUrl = 'https://api.temboplus.com/tembo/v1';

  static String get baseUrl => isProduction ? productionBaseUrl : sandboxBaseUrl;

  /// Default API Credentials
  /// In production, these should be supplied via environment variables or secure storage
  static const String accountId = 'bfa_merchant_acc_001';
  static const String secretKey = 'tembo_sec_live_bfa_farm_market_2026';

  /// Default Webhook Callback URL
  static const String defaultCallbackUrl = 'https://api.bfa.co.tz/api/v1/payments/tembo/callback';

  /// Supported Mobile Money Channels in Tanzania
  static const String channelVodacomMpesa = 'TZ-VODACOM-C2B';
  static const String channelTigoPesa = 'TZ-TIGO-C2B';
  static const String channelAirtelMoney = 'TZ-AIRTEL-C2B';
  static const String channelHalotelHaloPesa = 'TZ-HALOTEL-C2B';

  /// Supported Mobile Money Channels in Kenya
  static const String channelSafaricomMpesa = 'KE-SAFARICOM-C2B';

  /// Status codes returned by TemboPlus
  static const String statusPendingAck = 'PENDING_ACK';
  static const String statusPaymentAccepted = 'PAYMENT_ACCEPTED';
  static const String statusPaymentRejected = 'PAYMENT_REJECTED';
  static const String statusInsufficientFunds = 'INSUFFICIENT_FUNDS';
  static const String statusProviderFailed = 'PROVIDER_FAILED';
  static const String statusGenericFailure = 'GENERIC_FAILURE';
  static const String statusSessionExpired = 'SESSION_EXPIRED';

  /// Format phone number to international MSISDN format required by Tembo
  /// Tanzania: starts with 255 (e.g. 255712345678)
  /// Kenya: starts with 254 (e.g. 254712345678)
  static String formatMsisdn(String phone, {String defaultCountryCode = '255'}) {
    // Strip non-digits
    String clean = phone.replaceAll(RegExp(r'\D'), '');

    if (clean.startsWith('0')) {
      clean = defaultCountryCode + clean.substring(1);
    } else if (clean.startsWith('+')) {
      clean = clean.substring(1);
    } else if (!clean.startsWith('255') && !clean.startsWith('254')) {
      clean = defaultCountryCode + clean;
    }
    return clean;
  }

  /// Map provider name to channel code
  static String getChannelCode(String provider, {String country = 'TZ'}) {
    final lower = provider.toLowerCase();
    if (country == 'KE' || lower.contains('safaricom')) {
      return channelSafaricomMpesa;
    }
    if (lower.contains('vodacom') || lower.contains('mpesa') || lower.contains('m-pesa')) {
      return channelVodacomMpesa;
    }
    if (lower.contains('tigo') || lower.contains('yas') || lower.contains('mixx')) {
      return channelTigoPesa;
    }
    if (lower.contains('airtel')) {
      return channelAirtelMoney;
    }
    if (lower.contains('halo') || lower.contains('viettel')) {
      return channelHalotelHaloPesa;
    }
    return channelVodacomMpesa;
  }
}
