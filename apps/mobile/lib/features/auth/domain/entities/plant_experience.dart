enum PlantExperience {
  beginner,
  houseplant,
  backyardGardener,
  professional;

  String get label => switch (this) {
    PlantExperience.beginner => 'Beginner',
    PlantExperience.houseplant => 'Houseplant keeper',
    PlantExperience.backyardGardener => 'Backyard gardener',
    PlantExperience.professional => 'Professional',
  };
}
