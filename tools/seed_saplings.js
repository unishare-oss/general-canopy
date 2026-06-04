// Seeds the `saplings` collection with Bangkok test data.
//
// Against the emulator (no credentials needed):
//   cd tools && npm install
//   node seed_saplings.js --emulator
//
// Against real Firestore (requires a service-account key):
//   node seed_saplings.js service-account.json
//   node seed_saplings.js service-account.json --clear   ← wipe first, then seed

const admin = require('firebase-admin');

const args = process.argv.slice(2);
const useEmulator = args.includes('--emulator');
const clearFirst = args.includes('--clear');
const keyPath = args.find((a) => !a.startsWith('--'));

if (useEmulator) {
  process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
  admin.initializeApp({ projectId: 'canopy-dev' });
} else {
  if (!keyPath) {
    console.error('Usage:');
    console.error('  node seed_saplings.js --emulator');
    console.error('  node seed_saplings.js <service-account.json> [--clear]');
    process.exit(1);
  }
  admin.initializeApp({ credential: admin.credential.cert(require('./' + keyPath)) });
}

const db = admin.firestore();

// color field: 6-digit hex WITHOUT leading '#'
// (Dart reads it as: Color(int.parse('0xFF$colorHex')))
const SAPLINGS = [
  {
    nickname: 'Jamu',
    species: 'Rain Tree',
    latin: 'Samanea saman',
    personality: 'The neighbourhood gentle giant. Spreads a canopy wide enough to shade an entire block and expects very little in return.',
    color: '5A9B6F',
    street: 'Phahonyothin Rd, Soi 7',
    neighborhood: 'Chatuchak',
    lat: 13.8028, lng: 100.5534,
    ageLabel: '~1 year', heightLabel: '1.8 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 4,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Hitachi%27s_tree_%28cropped%29.jpg/960px-Hitachi%27s_tree_%28cropped%29.jpg',
  },
  {
    nickname: 'Dokfah',
    species: 'Golden Shower Tree',
    latin: 'Cassia fistula',
    personality: 'Shy all year, then explodes in blinding yellow every April. Absolutely worth the wait.',
    color: 'F2C94C',
    street: 'Silom Rd, near BTS Sala Daeng',
    neighborhood: 'Silom',
    lat: 13.7267, lng: 100.5277,
    ageLabel: '~8 months', heightLabel: '1.4 m',
    waterNeedLabel: 'Low–Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 5,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Golden_shower_tree.jpg/960px-Golden_shower_tree.jpg',
  },
  {
    nickname: 'Nok',
    species: 'Flame Tree',
    latin: 'Delonix regia',
    personality: 'Sets the sky on fire every summer. Zero apologies. Peak drama, maximum beauty.',
    color: 'E05B3C',
    street: 'Lat Phrao Rd, Soi 15',
    neighborhood: 'Lat Phrao',
    lat: 13.7932, lng: 100.5847,
    ageLabel: '~10 months', heightLabel: '1.6 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 4,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Royal_Poinciana.jpg/960px-Royal_Poinciana.jpg',
  },
  {
    nickname: 'Bua',
    species: 'Pink Trumpet Tree',
    latin: 'Tabebuia rosea',
    personality: 'Blooms before her leaves arrive — a true show-off who never misses her entrance.',
    color: 'E8A0C8',
    street: 'Phahonyothin Soi 5',
    neighborhood: 'Ari',
    lat: 13.7815, lng: 100.5453,
    ageLabel: '~6 months', heightLabel: '1.2 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 3,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Roblemorado.jpg/960px-Roblemorado.jpg',
  },
  {
    nickname: 'Tawan',
    species: 'Yellow Flame',
    latin: 'Peltophorum pterocarpum',
    personality: 'Steady, dependable, drought-tolerant. The friend who shows up on time every time.',
    color: 'F6A623',
    street: 'Sukhumvit Soi 55',
    neighborhood: 'Thonglor',
    lat: 13.7293, lng: 100.5847,
    ageLabel: '~14 months', heightLabel: '2.0 m',
    waterNeedLabel: 'Low', lightLabel: 'Full sun',
    wateringIntervalDays: 7,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Starr_030514-0025_Peltophorum_pterocarpum.jpg/960px-Starr_030514-0025_Peltophorum_pterocarpum.jpg',
  },
  {
    nickname: 'Mak',
    species: 'Bodhi Tree',
    latin: 'Ficus religiosa',
    personality: 'Deeply rooted — literally and philosophically. Plans to be here for the next five centuries.',
    color: '7BAE6E',
    street: 'Bang Na Nua Rd',
    neighborhood: 'Bang Na',
    lat: 13.6725, lng: 100.5987,
    ageLabel: '~2 years', heightLabel: '2.5 m',
    waterNeedLabel: 'Low', lightLabel: 'Full sun',
    wateringIntervalDays: 7,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/94/Ficus_religiosa_Bo.jpg',
  },
  {
    nickname: 'Tamarind Terry',
    species: 'Tamarind',
    latin: 'Tamarindus indica',
    personality: 'Sweet and sour in equal measure. Feeds birds, shades walkers, and drops fruit bombs with no warning.',
    color: 'A0724A',
    street: 'King Kaew Rd, Soi 3',
    neighborhood: 'Ladkrabang',
    lat: 13.7224, lng: 100.7501,
    ageLabel: '~18 months', heightLabel: '2.2 m',
    waterNeedLabel: 'Low', lightLabel: 'Full sun',
    wateringIntervalDays: 7,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Tamarindus_indica_pods.JPG',
  },
  {
    nickname: 'Ploy',
    species: 'Indian Coral Tree',
    latin: 'Erythrina variegata',
    personality: 'Leafless and blazing red in spring — looks like she skipped the outfit and wore only jewellery.',
    color: 'C0392B',
    street: 'Ratchadaphisek Rd, Soi 12',
    neighborhood: 'Ratchada',
    lat: 13.7713, lng: 100.5758,
    ageLabel: '~9 months', heightLabel: '1.5 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 4,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Indian_coral_tree_Munnar_Kerala_Erythrina_variegata.jpg/960px-Indian_coral_tree_Munnar_Kerala_Erythrina_variegata.jpg',
  },
  {
    nickname: 'Wan',
    species: 'Indian Tulip',
    latin: 'Thespesia populnea',
    personality: 'Salt air, sea breeze, no complaints. Quietly holds the line wherever others give up.',
    color: '8FBC8F',
    street: 'On Nut Rd, Soi 17',
    neighborhood: 'On Nut',
    lat: 13.7011, lng: 100.5998,
    ageLabel: '~7 months', heightLabel: '1.3 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 4,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Starr_070124-3910_Thespesia_populnea.jpg/960px-Starr_070124-3910_Thespesia_populnea.jpg',
  },
  {
    nickname: 'Sak',
    species: 'Teak',
    latin: 'Tectona grandis',
    personality: 'Will be furniture in 50 years, but for now is just trying to make friends.',
    color: 'C4A87A',
    street: 'Na Phra That Rd',
    neighborhood: 'Phra Nakhon',
    lat: 13.7547, lng: 100.4929,
    ageLabel: '~1 year', heightLabel: '1.9 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 5,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Starr_010304-0485_Tectona_grandis.jpg/960px-Starr_010304-0485_Tectona_grandis.jpg',
  },
  {
    nickname: 'Ruen',
    species: 'Cannonball Tree',
    latin: 'Couroupita guianensis',
    personality: 'Grows flowers straight out of her trunk. Biologically overachieving and proud of it.',
    color: 'D4A043',
    street: 'Charoenkrung Rd, Soi 28',
    neighborhood: 'Bangrak',
    lat: 13.7224, lng: 100.5158,
    ageLabel: '~11 months', heightLabel: '1.7 m',
    waterNeedLabel: 'Moderate', lightLabel: 'Partial shade',
    wateringIntervalDays: 3,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Naglingam_%28Couroupita_guianensis%29_flower_in_Hyderabad%2C_AP_W_IMG_6609.jpg',
  },
  {
    nickname: 'Chai',
    species: 'Copper Pod',
    latin: 'Peltophorum pterocarpum',
    personality: 'Fast-growing, fast-flowering, and very aware of it. The overachiever of the block.',
    color: 'E09B3A',
    street: 'Lat Phrao Rd, Soi 80',
    neighborhood: 'Huai Khwang',
    lat: 13.7748, lng: 100.5793,
    ageLabel: '~5 months', heightLabel: '1.1 m',
    waterNeedLabel: 'Low–Moderate', lightLabel: 'Full sun',
    wateringIntervalDays: 5,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Starr_030514-0025_Peltophorum_pterocarpum.jpg/960px-Starr_030514-0025_Peltophorum_pterocarpum.jpg',
  },
  {
    nickname: 'Luna',
    species: 'Alexandrian Laurel',
    latin: 'Calophyllum inophyllum',
    personality: 'Dense, fragrant, and completely unimpressed by coastal storms. Built different.',
    color: '4A7C59',
    street: 'Ramkhamhaeng Rd, Soi 10',
    neighborhood: 'Bang Kapi',
    lat: 13.7627, lng: 100.6351,
    ageLabel: '~16 months', heightLabel: '2.1 m',
    waterNeedLabel: 'Low', lightLabel: 'Full sun',
    wateringIntervalDays: 7,
    status: 'available', adoptedBy: null,
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Starr_010309-0546_Calophyllum_inophyllum.jpg/960px-Starr_010309-0546_Calophyllum_inophyllum.jpg',
  },
  // One already-adopted sapling so the map shows a faded pin
  {
    nickname: 'Pruk',
    species: 'Golden Shower Tree',
    latin: 'Cassia fistula',
    personality: 'Already claimed — thriving under the care of a dedicated guardian.',
    color: 'F2C94C',
    street: 'Viphavadi Rangsit Rd, Soi 2',
    neighborhood: 'Don Mueang',
    lat: 13.9185, lng: 100.5978,
    ageLabel: '~2 years', heightLabel: '2.4 m',
    waterNeedLabel: 'Low', lightLabel: 'Full sun',
    wateringIntervalDays: 7,
    status: 'adopted', adoptedBy: 'seed-user-placeholder',
    photoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Golden_shower_tree.jpg/960px-Golden_shower_tree.jpg',
  },
];

async function clearCollection() {
  const snap = await db.collection('saplings').get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  console.log(`Cleared ${snap.size} existing sapling(s).`);
}

async function run() {
  if (clearFirst) await clearCollection();

  const batch = db.batch();
  for (const s of SAPLINGS) {
    batch.set(db.collection('saplings').doc(), s);
  }
  await batch.commit();
  console.log(`Seeded ${SAPLINGS.length} saplings (${SAPLINGS.filter(s => s.status === 'available').length} available, ${SAPLINGS.filter(s => s.status === 'adopted').length} adopted).`);
  console.log('Done.');
}

run().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
