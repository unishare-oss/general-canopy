// Canopy mock data — trees, badges, feed events
// Exports to window for sibling babel scripts.

const TREES = [
  {
    id: 't1', nickname: 'Olive', species: 'Eastern Redbud', latin: 'Cercis canadensis',
    age: 'Sapling · 6mo', height: '1.2m', street: '142 Linden Ave',
    distance: '0.2 mi', neighborhood: 'Maple Heights',
    personality: 'A shy understudy with heart-shaped leaves. Loves morning sun, hates being forgotten.',
    waterNeed: 'Every 3 days in summer', light: 'Partial sun',
    status: 'available', health: null, color: '#D87FA8',
    lat: 0.42, lng: 0.31,
  },
  {
    id: 't2', nickname: 'Bramble', species: 'Sugar Maple', latin: 'Acer saccharum',
    age: 'Sapling · 1yr', height: '1.8m', street: '88 Cedar St',
    distance: '0.4 mi', neighborhood: 'Maple Heights',
    personality: 'A future towering shade-giver. Currently extremely dramatic about every breeze.',
    waterNeed: 'Twice weekly', light: 'Full sun',
    status: 'available', health: null, color: '#E8843A',
    lat: 0.62, lng: 0.48,
  },
  {
    id: 't3', nickname: 'Sprout', species: 'Flowering Dogwood', latin: 'Cornus florida',
    age: 'Sapling · 8mo', height: '1.4m', street: '210 Birchwood Ln',
    distance: '0.6 mi', neighborhood: 'East Park',
    personality: 'Quietly preparing the most extra spring bloom of your life.',
    waterNeed: 'Every 4 days', light: 'Dappled shade',
    status: 'available', health: null, color: '#F4F0D8',
    lat: 0.28, lng: 0.71,
  },
  {
    id: 't4', nickname: 'Pip', species: 'Red Oak', latin: 'Quercus rubra',
    age: 'Sapling · 2yr', height: '2.4m', street: '15 Oakridge Way',
    distance: '0.8 mi', neighborhood: 'Westgate',
    personality: 'The strong silent type. Plans to outlive everyone you know.',
    waterNeed: 'Weekly', light: 'Full sun',
    status: 'available', health: null, color: '#A65A3A',
    lat: 0.78, lng: 0.22,
  },
  {
    id: 't5', nickname: 'Juniper', species: 'River Birch', latin: 'Betula nigra',
    age: 'Sapling · 1yr', height: '2.0m', street: '67 Willow Bend',
    distance: '1.1 mi', neighborhood: 'Riverside',
    personality: 'Peeling bark like she means it. Thrives where others get cold feet.',
    waterNeed: 'Twice weekly', light: 'Full sun',
    status: 'available', health: null, color: '#D9C9A8',
    lat: 0.18, lng: 0.18,
  },
  // user-adopted
  {
    id: 't10', nickname: 'Theodora', species: 'Tulip Poplar', latin: 'Liriodendron tulipifera',
    age: 'Sapling · 14mo', height: '2.1m', street: '24 Elm St',
    distance: '0.1 mi', neighborhood: 'Maple Heights',
    personality: 'Adopted in spring. Loves a deep drink and rewards you with extravagant yellow blooms.',
    waterNeed: 'Every 3 days', light: 'Full sun',
    status: 'adopted', health: 'healthy', healthScore: 92,
    adoptedDate: 'Mar 12, 2026', daysSince: 68,
    lastWatered: '2 days ago', nextWaterIn: 1, // days
    waterStreak: 12, photoCount: 4,
    color: '#9CC066',
    lat: 0.5, lng: 0.5,
  },
  {
    id: 't11', nickname: 'Mossback', species: 'White Pine', latin: 'Pinus strobus',
    age: 'Sapling · 2yr', height: '2.6m', street: '102 Pinegrove',
    distance: '0.3 mi', neighborhood: 'Maple Heights',
    personality: 'Evergreen mood. Soft needles, soft attitude.',
    waterNeed: 'Weekly', light: 'Full sun',
    status: 'adopted', health: 'attention', healthScore: 74,
    adoptedDate: 'Jan 4, 2026', daysSince: 136,
    lastWatered: '5 days ago', nextWaterIn: -1, // overdue
    waterStreak: 4, photoCount: 6,
    color: '#5B7C5F',
    lat: 0.36, lng: 0.62,
  },
  {
    id: 't12', nickname: 'Marlow', species: 'American Sycamore', latin: 'Platanus occidentalis',
    age: 'Sapling · 9mo', height: '1.6m', street: '50 Riverside Dr',
    distance: '0.5 mi', neighborhood: 'Riverside',
    personality: 'Mottled bark, big mood, will eventually shade an entire intersection.',
    waterNeed: 'Every 3 days', light: 'Full sun',
    status: 'adopted', health: 'healthy', healthScore: 88,
    adoptedDate: 'Apr 22, 2026', daysSince: 28,
    lastWatered: 'Today', nextWaterIn: 3,
    waterStreak: 8, photoCount: 2,
    color: '#C8B582',
    lat: 0.66, lng: 0.4,
  },
];

const BADGES = [
  { id: 'b1', name: 'First Adoption', icon: 'ph-seedling', earned: true, date: 'Mar 12' },
  { id: 'b2', name: '30-Day Streak', icon: 'ph-flame', earned: true, date: 'Apr 11' },
  { id: 'b3', name: 'Survived First Summer', icon: 'ph-sun', earned: false, progress: 0.62 },
  { id: 'b4', name: 'Photo Diarist', icon: 'ph-camera', earned: true, date: 'Apr 26' },
  { id: 'b5', name: 'Grove of Three', icon: 'ph-tree', earned: true, date: 'Apr 28' },
  { id: 'b6', name: 'Storm Watch', icon: 'ph-cloud-rain', earned: false, progress: 0.3 },
  { id: 'b7', name: 'Block Leader', icon: 'ph-crown-simple', earned: false, progress: 0.0 },
  { id: 'b8', name: 'Drought Hero', icon: 'ph-drop', earned: false, progress: 0.15 },
];

const LEADERBOARD = [
  { rank: 1, name: 'Soraya M.', neighborhood: 'East Park', trees: 6, streak: 124, you: false },
  { rank: 2, name: 'Marcus J.', neighborhood: 'Maple Heights', trees: 5, streak: 98, you: false },
  { rank: 3, name: 'You (Ren)', neighborhood: 'Maple Heights', trees: 3, streak: 68, you: true },
  { rank: 4, name: 'Aiyana P.', neighborhood: 'Westgate', trees: 4, streak: 61, you: false },
  { rank: 5, name: 'Devon R.', neighborhood: 'Riverside', trees: 3, streak: 54, you: false },
  { rank: 6, name: 'Kim L.', neighborhood: 'East Park', trees: 3, streak: 47, you: false },
  { rank: 7, name: 'Hassan T.', neighborhood: 'Maple Heights', trees: 2, streak: 41, you: false },
];

const FEED = [
  { id: 'f1', who: 'Soraya M.', what: 'adopted', tree: 'Quincy', species: 'Pin Oak', when: '12 min ago' },
  { id: 'f2', who: 'Marcus J.', what: 'photographed', tree: 'Beatrix', species: 'Sugar Maple', when: '34 min ago' },
  { id: 'f3', who: 'You', what: 'watered', tree: 'Theodora', species: 'Tulip Poplar', when: '2 hr ago' },
  { id: 'f4', who: 'Aiyana P.', what: 'reported issue on', tree: 'Hazel', species: 'River Birch', when: '4 hr ago' },
  { id: 'f5', who: 'Devon R.', what: 'reached 30-day streak with', tree: 'Smokey', species: 'Black Walnut', when: '6 hr ago' },
  { id: 'f6', who: 'Kim L.', what: 'adopted', tree: 'Brennan', species: 'Eastern Redbud', when: '1 day ago' },
];

// Admin sample data
const ADMIN_TREES = [
  { id: 'a1', code: 'CB-0481', species: 'Sugar Maple', street: 'Linden Ave', planted: 'Oct 2025', status: 'adopted', guardian: 'Ren K.', health: 'healthy' },
  { id: 'a2', code: 'CB-0482', species: 'White Pine', street: 'Pinegrove Rd', planted: 'Oct 2025', status: 'adopted', guardian: 'Ren K.', health: 'attention' },
  { id: 'a3', code: 'CB-0483', species: 'Eastern Redbud', street: 'Linden Ave', planted: 'Oct 2025', status: 'available', guardian: '—', health: null },
  { id: 'a4', code: 'CB-0484', species: 'Red Oak', street: 'Oakridge Way', planted: 'Apr 2024', status: 'available', guardian: '—', health: null },
  { id: 'a5', code: 'CB-0470', species: 'American Sycamore', street: 'Riverside Dr', planted: 'Apr 2024', status: 'adopted', guardian: 'Ren K.', health: 'healthy' },
  { id: 'a6', code: 'CB-0451', species: 'River Birch', street: 'Willow Bend', planted: 'Apr 2024', status: 'available', guardian: '—', health: null },
  { id: 'a7', code: 'CB-0440', species: 'Tulip Poplar', street: 'Elm St', planted: 'Mar 2025', status: 'adopted', guardian: 'Ren K.', health: 'healthy' },
  { id: 'a8', code: 'CB-0429', species: 'Flowering Dogwood', street: 'Birchwood Ln', planted: 'Mar 2025', status: 'available', guardian: '—', health: null },
  { id: 'a9', code: 'CB-0388', species: 'Honey Locust', street: 'Main St', planted: 'Apr 2024', status: 'dead', guardian: 'M. Jones (resigned)', health: 'risk' },
];

window.CANOPY_DATA = { TREES, BADGES, LEADERBOARD, FEED, ADMIN_TREES };
