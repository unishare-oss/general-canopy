// Seeds the `admins` collection for first-admin bootstrap.
//
// Usage against the Firestore emulator (no credentials needed):
//   cd tools && npm install
//   node seed_admins.js --emulator
//
// Usage against real Firestore (requires a service-account key):
//   node seed_admins.js service-account.json
//
// Replace 'REPLACE_WITH_YOUR_UID' with the Firebase Auth UID of the first
// admin user before running. You can find the UID in the Firebase Console
// under Authentication > Users, or by logging in and reading
// firebase.auth().currentUser.uid in the browser console.
//
// Once the first admin document is created via this script, subsequent admins
// can be granted programmatically through the app (GrantAdmin use case) because
// the Firestore rule only allows an existing admin to create new admin docs.

const admin = require('firebase-admin');

const ADMINS = [
  { uid: '2uV98bLciuXoLTHlWYEa3dIPfjo1' },
];

const args = process.argv.slice(2);
const useEmulator = args.includes('--emulator');
const keyPath = args.find((a) => !a.startsWith('--'));

if (useEmulator) {
  process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
  admin.initializeApp({ projectId: 'canopy-dev' });
} else {
  if (!keyPath) {
    console.error('Usage:');
    console.error('  node seed_admins.js --emulator');
    console.error('  node seed_admins.js <service-account.json>');
    process.exit(1);
  }
  admin.initializeApp({
    credential: admin.credential.cert(require('./' + keyPath)),
  });
}

const db = admin.firestore();

async function run() {
  const batch = db.batch();
  for (const { uid } of ADMINS) {
    if (uid === 'REPLACE_WITH_YOUR_UID') {
      console.warn(
        `[WARN] Skipping placeholder UID "${uid}". Update ADMINS in this file first.`,
      );
      continue;
    }
    batch.set(db.collection('admins').doc(uid), { isAdmin: true });
  }
  await batch.commit();
  const seeded = ADMINS.filter((a) => a.uid !== 'REPLACE_WITH_YOUR_UID');
  console.log(`Seeded ${seeded.length} admin(s).`);
  console.log('Done.');
}

run()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
