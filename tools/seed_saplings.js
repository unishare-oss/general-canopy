// Seeds the `saplings` collection. Usage:
//   cd tools && npm install
//   node seed_saplings.js service-account.json
const admin = require('firebase-admin');

const keyPath = process.argv[2];
if (!keyPath) {
  console.error('Usage: node seed_saplings.js <service-account.json>');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(require('./' + keyPath)) });
const db = admin.firestore();

const SAPLINGS = [
  { nickname: 'Olive', species: 'Eastern Redbud', latin: 'Cercis canadensis',
    personality: 'A shy understudy with heart-shaped leaves. Loves morning sun, hates being forgotten.',
    color: '#D87FA8', street: '142 Linden Ave', neighborhood: 'Maple Heights', lat: 0.42, lng: 0.31,
    ageLabel: 'Sapling · 6mo', heightLabel: '1.2m', waterNeedLabel: 'Every 3 days in summer',
    lightLabel: 'Partial sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Bramble', species: 'Sugar Maple', latin: 'Acer saccharum',
    personality: 'A future towering shade-giver. Currently extremely dramatic about every breeze.',
    color: '#E8843A', street: '88 Cedar St', neighborhood: 'Maple Heights', lat: 0.62, lng: 0.48,
    ageLabel: 'Sapling · 1yr', heightLabel: '1.8m', waterNeedLabel: 'Twice weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Sprout', species: 'Flowering Dogwood', latin: 'Cornus florida',
    personality: 'Quietly preparing the most extra spring bloom of your life.',
    color: '#F4F0D8', street: '210 Birchwood Ln', neighborhood: 'East Park', lat: 0.28, lng: 0.71,
    ageLabel: 'Sapling · 8mo', heightLabel: '1.4m', waterNeedLabel: 'Every 4 days',
    lightLabel: 'Dappled shade', wateringIntervalDays: 4, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Pip', species: 'Red Oak', latin: 'Quercus rubra',
    personality: 'The strong silent type. Plans to outlive everyone you know.',
    color: '#A65A3A', street: '15 Oakridge Way', neighborhood: 'Westgate', lat: 0.78, lng: 0.22,
    ageLabel: 'Sapling · 2yr', heightLabel: '2.4m', waterNeedLabel: 'Weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 7, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Juniper', species: 'River Birch', latin: 'Betula nigra',
    personality: 'Peeling bark like she means it. Thrives where others get cold feet.',
    color: '#D9C9A8', street: '67 Willow Bend', neighborhood: 'Riverside', lat: 0.18, lng: 0.18,
    ageLabel: 'Sapling · 1yr', heightLabel: '2.0m', waterNeedLabel: 'Twice weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Hazel', species: 'Pin Oak', latin: 'Quercus palustris',
    personality: 'Symmetrical to a fault. Will judge your fence.',
    color: '#B5743A', street: '9 Park Row', neighborhood: 'East Park', lat: 0.34, lng: 0.66,
    ageLabel: 'Sapling · 10mo', heightLabel: '1.7m', waterNeedLabel: 'Every 3 days',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Smokey', species: 'Black Walnut', latin: 'Juglans nigra',
    personality: 'Generous with shade, stingy with neighbors. Complicated.',
    color: '#6E5638', street: '301 Walnut Ct', neighborhood: 'Westgate', lat: 0.7, lng: 0.3,
    ageLabel: 'Sapling · 18mo', heightLabel: '2.2m', waterNeedLabel: 'Weekly',
    lightLabel: 'Full sun', wateringIntervalDays: 7, status: 'available', adoptedBy: null, photoUrl: null },
  { nickname: 'Quincy', species: 'Tulip Poplar', latin: 'Liriodendron tulipifera',
    personality: 'Reaches for the sky and expects you to keep up.',
    color: '#9CC066', street: '54 Elm St', neighborhood: 'Maple Heights', lat: 0.52, lng: 0.52,
    ageLabel: 'Sapling · 7mo', heightLabel: '1.5m', waterNeedLabel: 'Every 3 days',
    lightLabel: 'Full sun', wateringIntervalDays: 3, status: 'available', adoptedBy: null, photoUrl: null },
];

async function run() {
  const batch = db.batch();
  for (const s of SAPLINGS) {
    batch.set(db.collection('saplings').doc(), s);
  }
  await batch.commit();
  console.log(`Seeded ${SAPLINGS.length} saplings.`);
}

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
