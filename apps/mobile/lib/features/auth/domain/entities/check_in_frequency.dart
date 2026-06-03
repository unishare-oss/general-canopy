enum CheckInFrequency {
  mostDays,
  onceAWeek,
  twiceAMonth;

  String get label => switch (this) {
    CheckInFrequency.mostDays => 'Most days',
    CheckInFrequency.onceAWeek => 'Once a week',
    CheckInFrequency.twiceAMonth => 'Twice a month',
  };
}
