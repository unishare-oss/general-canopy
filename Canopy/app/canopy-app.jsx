// canopy-app.jsx — root App, wires tabs/screens together, owns Tweaks panel

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "dark": false,
  "accent": "#2F7D4F",
  "pinStyle": "pin",
  "navStyle": "labeled",
  "density": "regular",
  "cardStyle": "a"
}/*EDITMODE-END*/;

const ACCENT_OPTIONS = [
  '#2F7D4F',  // leaf — default
  '#4A8C3A',  // brighter spring
  '#5B7C5F',  // sage / muted
  '#1F5A38',  // deep forest
];

function CanopyApp({ initialTab = 'grove', initialScreen = null, initialTreeId = null, fixedTweaks = null, embedded = false }) {
  // Tweaks (state shared in TweaksPanel mode; in canvas mode passed via fixedTweaks)
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const tweaks = fixedTweaks || t;

  // Sync dark mode to document root so phone chrome can theme itself
  useEffect(() => {
    if (!embedded) {
      document.documentElement.setAttribute('data-theme', tweaks.dark ? 'dark' : 'light');
      document.documentElement.style.setProperty('--app-accent', tweaks.accent);
    }
  }, [tweaks.dark, tweaks.accent, embedded]);

  // App navigation state
  const [tab, setTab] = useState(initialTab);
  const [stack, setStack] = useState(initialScreen ? [{ kind: initialScreen, treeId: initialTreeId }] : []);
  const [sheet, setSheet] = useState(null); // 'water-{id}' | null
  const [modal, setModal] = useState(null); // 'photo' | 'health' | 'cert' | 'admin' | null
  const [toast, setToast] = useState(null);

  // Tree state — start with seed data; allow swipe to mark adopted
  const [trees, setTrees] = useState(window.CANOPY_DATA.TREES);

  const pushScreen = (kind, treeId) => setStack(s => [...s, { kind, treeId }]);
  const popScreen = () => setStack(s => s.slice(0, -1));

  const adoptTree = (id) => {
    setTrees(ts => ts.map(t => t.id === id ? {
      ...t, status: 'adopted', health: 'healthy', healthScore: 88,
      adoptedDate: 'Today', daysSince: 0, lastWatered: 'Just now',
      nextWaterIn: 3, waterStreak: 1, photoCount: 1,
    } : t));
  };

  const showToast = (msg, icon = 'ph-check') => {
    setToast({ msg, icon });
    setTimeout(() => setToast(null), 2200);
  };

  const treeById = (id) => trees.find(t => t.id === id);

  // Apply theme + density on root
  const accentRgb = hexToRgb(tweaks.accent);
  const rootStyle = {
    '--primary': tweaks.accent,
    '--primary-deep': shade(tweaks.accent, -20),
    '--primary-light': shade(tweaks.accent, 20),
    '--primary-surface': lighten(tweaks.accent, 0.88),
    '--primary-muted': lighten(tweaks.accent, 0.65),
  };

  const topScreen = stack[stack.length - 1];

  return (
    <div className="canopy-root" data-theme={tweaks.dark ? 'dark' : 'light'} data-density={tweaks.density} style={rootStyle}>
      {/* Main tab content */}
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column' }}>
        {tab === 'discover' && (
          <DiscoverScreen
            trees={trees}
            cardStyle={tweaks.cardStyle}
            onAdopt={(id) => { adoptTree(id); }}
            onOpenTree={(id) => pushScreen('tree', id)}
          />
        )}
        {tab === 'map' && (
          <MapScreen trees={trees} pinStyle={tweaks.pinStyle}
            onOpenTree={(id) => pushScreen('tree', id)} />
        )}
        {tab === 'grove' && (
          <GroveScreen trees={trees}
            onOpenTree={(id) => pushScreen('tree', id)}
            onWater={(id) => setSheet({ kind: 'water', treeId: id })}
            onAddTree={() => setTab('discover')}
          />
        )}
        {tab === 'impact' && (
          <ImpactScreen data={window.CANOPY_DATA} />
        )}
        {tab === 'you' && (
          <YouScreen
            onOpenAdmin={() => setModal('admin')}
            onOpenOnboarding={() => setModal('onboarding')}
          />
        )}

        {/* Bottom nav (hidden when a push-screen or full modal is open) */}
        {!topScreen && !modal && (
          <BottomNav active={tab} onChange={setTab} labeled={tweaks.navStyle === 'labeled'} />
        )}
      </div>

      {/* Push screens (above tabs) */}
      {topScreen && topScreen.kind === 'tree' && (
        <div style={{ position: 'absolute', inset: 0, background: 'var(--surface)' }}>
          <TreeProfile
            tree={treeById(topScreen.treeId)}
            onBack={popScreen}
            onWater={() => setSheet({ kind: 'water', treeId: topScreen.treeId })}
            onPhoto={() => setModal('photo')}
            onHealth={() => setModal('health')}
            onCertificate={() => setModal('cert')}
            onAdopt={() => { adoptTree(topScreen.treeId); showToast(`${treeById(topScreen.treeId)?.nickname} adopted!`, 'ph-heart'); }}
          />
        </div>
      )}

      {/* Bottom sheets */}
      {sheet?.kind === 'water' && (
        <WaterSheet tree={treeById(sheet.treeId)}
          onClose={() => setSheet(null)}
          onConfirm={({ amount, soil }) => {
            setSheet(null);
            showToast(`Logged ${amount}L for ${treeById(sheet.treeId)?.nickname}`, 'ph-drop');
            setTrees(ts => ts.map(t => t.id === sheet.treeId ? {
              ...t, lastWatered: 'Just now', nextWaterIn: 3, waterStreak: (t.waterStreak || 0) + 1,
            } : t));
          }}
        />
      )}

      {/* Full-screen modals */}
      {modal === 'photo' && (
        <PhotoCheckIn tree={treeById(topScreen?.treeId)}
          onClose={() => setModal(null)}
          onConfirm={() => { setModal(null); showToast('Check-in saved', 'ph-camera'); }}
        />
      )}
      {modal === 'health' && (
        <HealthLog tree={treeById(topScreen?.treeId)}
          onClose={() => setModal(null)}
          onConfirm={() => { setModal(null); showToast('Health report saved', 'ph-leaf'); }}
        />
      )}
      {modal === 'cert' && (
        <Certificate tree={treeById(topScreen?.treeId)}
          onClose={() => setModal(null)}
        />
      )}
      {modal === 'admin' && (
        <AdminView data={window.CANOPY_DATA} onClose={() => setModal(null)} />
      )}
      {modal === 'onboarding' && (
        <OnboardingQuiz onClose={() => setModal(null)} />
      )}

      {/* Toast */}
      {toast && (
        <div style={{
          position: 'absolute', left: 16, right: 16, bottom: 96, zIndex: 60,
          background: 'var(--surface-dark)', color: 'var(--on-dark)',
          padding: '12px 16px', borderRadius: 'var(--radius-md)',
          display: 'flex', alignItems: 'center', gap: 10,
          boxShadow: 'var(--elev-3)',
          animation: 'canopy-fade-up 200ms var(--ease-out)',
        }}>
          <i className={`ph-fill ${toast.icon} pi`} style={{ color: 'var(--primary-light)' }}></i>
          <span className="body-md">{toast.msg}</span>
        </div>
      )}

      {/* Tweaks panel — only on main app, not in canvas embeds */}
      {!embedded && (
        <TweaksPanel title="Canopy Tweaks">
          <TweakSection label="Theme" />
          <TweakToggle label="Dark mode" value={tweaks.dark} onChange={(v) => setTweak('dark', v)} />
          <TweakColor label="Accent" value={tweaks.accent}
            options={ACCENT_OPTIONS} onChange={(v) => setTweak('accent', v)} />

          <TweakSection label="Layout" />
          <TweakRadio label="Density" value={tweaks.density}
            options={['compact', 'regular', 'comfy']}
            onChange={(v) => setTweak('density', v)} />
          <TweakRadio label="Nav" value={tweaks.navStyle}
            options={[{ value: 'labeled', label: 'Labeled' }, { value: 'icons', label: 'Icons only' }]}
            onChange={(v) => setTweak('navStyle', v)} />

          <TweakSection label="Map" />
          <TweakRadio label="Pin style" value={tweaks.pinStyle}
            options={[
              { value: 'pin', label: 'Pin' },
              { value: 'leaf', label: 'Leaf' },
              { value: 'dot', label: 'Dot' },
              { value: 'tree', label: 'Tree' },
            ]}
            onChange={(v) => setTweak('pinStyle', v)} />

          <TweakSection label="Discover deck" />
          <TweakRadio label="Card style" value={tweaks.cardStyle}
            options={[
              { value: 'a', label: 'Photo' },
              { value: 'b', label: 'Full-bleed' },
              { value: 'c', label: 'Specimen' },
            ]}
            onChange={(v) => setTweak('cardStyle', v)} />

          <TweakSection label="Quick demo" />
          <TweakButton label="Open certificate" onClick={() => setModal('cert')} />
          <TweakButton label="Open admin view" onClick={() => setModal('admin')} />
        </TweaksPanel>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// OnboardingQuiz — a small modal for the onboarding flow
// ─────────────────────────────────────────────────────────────
function OnboardingQuiz({ onClose }) {
  const [step, setStep] = useState(0);
  const steps = [
    {
      title: 'Welcome to Canopy.', sub: 'Adopt a tree on your block, keep it alive, cool your city.',
      illust: <TreeIllustration species="Sugar Maple" color="#9CC066" size={200} />,
      cta: 'Get started',
    },
    {
      title: 'Where do you live?', sub: 'We\'ll show you saplings within walking distance.',
      input: (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {['Maple Heights', 'East Park', 'Westgate', 'Riverside'].map((n, i) => (
            <button key={n} style={{
              padding: '14px 16px', textAlign: 'left',
              background: i === 0 ? 'var(--primary-surface)' : 'var(--surface-card)',
              border: `1px solid ${i === 0 ? 'var(--primary)' : 'var(--hairline)'}`,
              borderRadius: 'var(--radius-md)', fontWeight: 600, color: 'var(--ink)',
            }}>
              <i className="ph ph-map-pin pi-sm" style={{ marginRight: 8, color: 'var(--primary)' }}></i>
              {n}
            </button>
          ))}
        </div>
      ),
      cta: 'Continue',
    },
    {
      title: 'How often can you check on a tree?',
      sub: 'You can change this later. We base watering reminders on this.',
      input: (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { l: 'Most days', s: 'I walk past it constantly' },
            { l: 'Once a week', s: 'I can swing by weekends', sel: true },
            { l: 'Twice a month', s: 'Light-touch guardian' },
          ].map((o) => (
            <button key={o.l} style={{
              padding: '14px 16px', textAlign: 'left',
              background: o.sel ? 'var(--primary-surface)' : 'var(--surface-card)',
              border: `1px solid ${o.sel ? 'var(--primary)' : 'var(--hairline)'}`,
              borderRadius: 'var(--radius-md)', color: 'var(--ink)',
            }}>
              <div style={{ fontWeight: 600 }}>{o.l}</div>
              <div className="caption" style={{ marginTop: 2 }}>{o.s}</div>
            </button>
          ))}
        </div>
      ),
      cta: 'Continue',
    },
    {
      title: 'Have you cared for plants before?',
      sub: 'We\'ll match you with the right starter trees.',
      input: (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          {[
            { l: 'Total beginner', i: 'ph-seedling' },
            { l: 'A houseplant or two', i: 'ph-plant', sel: true },
            { l: 'Backyard gardener', i: 'ph-flower-tulip' },
            { l: 'Professional', i: 'ph-tree' },
          ].map((o) => (
            <button key={o.l} style={{
              padding: 14, textAlign: 'left',
              background: o.sel ? 'var(--primary-surface)' : 'var(--surface-card)',
              border: `1px solid ${o.sel ? 'var(--primary)' : 'var(--hairline)'}`,
              borderRadius: 'var(--radius-md)', color: 'var(--ink)',
            }}>
              <i className={`ph-duotone ${o.i} pi`} style={{ fontSize: 24, color: 'var(--primary)' }}></i>
              <div style={{ fontWeight: 600, fontSize: 13, marginTop: 6 }}>{o.l}</div>
            </button>
          ))}
        </div>
      ),
      cta: 'Find me a tree',
    },
  ];
  const s = steps[step];
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'var(--surface)', zIndex: 50, display: 'flex', flexDirection: 'column' }} className="slide-in">
      <div style={{ padding: '12px 12px', display: 'flex', alignItems: 'center' }}>
        <button onClick={step > 0 ? () => setStep(step - 1) : onClose} style={{ width: 40, height: 40, border: 'none', background: 'transparent', color: 'var(--ink)' }}>
          <i className="ph-bold ph-arrow-left pi"></i>
        </button>
        <div style={{ flex: 1, display: 'flex', gap: 4, justifyContent: 'center' }}>
          {steps.map((_, i) => (
            <div key={i} style={{
              width: 24, height: 4, borderRadius: 2,
              background: i <= step ? 'var(--primary)' : 'var(--surface-overlay)',
            }}></div>
          ))}
        </div>
        <button onClick={onClose} style={{ width: 40, height: 40, border: 'none', background: 'transparent', color: 'var(--ink-tertiary)', fontSize: 13 }}>
          Skip
        </button>
      </div>
      <div style={{ flex: 1, padding: '12px 24px', display: 'flex', flexDirection: 'column', justifyContent: 'flex-start' }}>
        {s.illust && (
          <div style={{ textAlign: 'center', margin: '20px 0' }}>{s.illust}</div>
        )}
        <div className="h-display" style={{ fontSize: 30, lineHeight: 1.15, textWrap: 'balance' }}>{s.title}</div>
        <div className="body-md" style={{ color: 'var(--ink-secondary)', marginTop: 8, textWrap: 'pretty' }}>{s.sub}</div>
        {s.input && <div style={{ marginTop: 24 }}>{s.input}</div>}
      </div>
      <div style={{ padding: 16 }}>
        <button className="btn block" onClick={() => step === steps.length - 1 ? onClose() : setStep(step + 1)}>
          {s.cta} <i className="ph-bold ph-arrow-right pi-sm"></i>
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Color helpers
// ─────────────────────────────────────────────────────────────
function hexToRgb(hex) {
  const m = hex.replace('#','').match(/.{2}/g);
  return m ? m.map(s => parseInt(s, 16)) : [0,0,0];
}
function shade(hex, percent) {
  const [r,g,b] = hexToRgb(hex);
  const adj = (c) => Math.max(0, Math.min(255, Math.round(c + (255 - c) * (percent / 100))));
  const dim = (c) => Math.max(0, Math.min(255, Math.round(c + c * (percent / 100))));
  const fn = percent > 0 ? adj : dim;
  return '#' + [r,g,b].map(c => fn(c).toString(16).padStart(2,'0')).join('');
}
function lighten(hex, amount) {
  // mix with white by `amount` (0 = original, 1 = white)
  const [r,g,b] = hexToRgb(hex);
  const m = (c) => Math.round(c + (255 - c) * amount);
  return '#' + [r,g,b].map(c => m(c).toString(16).padStart(2,'0')).join('');
}

Object.assign(window, { CanopyApp, OnboardingQuiz, TWEAK_DEFAULTS, ACCENT_OPTIONS });
