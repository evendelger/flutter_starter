/// Информация о приложении и устройстве
class AppDeviceInfo {
  AppDeviceInfo({
    required this.platform,
    required this.deviceModel,
    required this.osVersion,
    required this.isPhysicalDevice,
    required this.appName,
    required this.packageName,
    required this.appVersion,
    required this.buildNumber,
    this.manufacturer,
    this.deviceId,
  });
  final String platform;
  final String deviceModel;
  final String osVersion;
  final String? manufacturer;
  final bool isPhysicalDevice;
  final String? deviceId;
  final String appName;
  final String packageName;
  final String appVersion;
  final String buildNumber;

  String get fullVersion =>
      '$appVersion ${buildNumber != '0' ? '($buildNumber)' : ''}'.trim();

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'manufacturer': manufacturer,
      'isPhysicalDevice': isPhysicalDevice,
      'deviceId': deviceId,
      'appName': appName,
      'packageName': packageName,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
    };
  }
}
