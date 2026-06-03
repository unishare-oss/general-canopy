class NotificationPreferences {
  const NotificationPreferences({
    this.wateringReminders = false,
    this.cityAlerts = false,
  });

  final bool wateringReminders;
  final bool cityAlerts;

  NotificationPreferences copyWith({
    bool? wateringReminders,
    bool? cityAlerts,
  }) => NotificationPreferences(
    wateringReminders: wateringReminders ?? this.wateringReminders,
    cityAlerts: cityAlerts ?? this.cityAlerts,
  );
}
