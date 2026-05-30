// canopy-modals.jsx — Water log sheet, Photo check-in, Health log form, Adoption certificate, Admin view

// ─────────────────────────────────────────────────────────────
// WaterSheet — bottom sheet for logging a watering
// ─────────────────────────────────────────────────────────────
function WaterSheet({ tree, onConfirm, onClose }) {
  const [amount, setAmount] = useState(4);
  const [soil, setSoil] = useState('dry');
  return (
    <>
      <div className="sheet-backdrop" onClick={onClose}></div>
      <div className="sheet">
        <div className="sheet-handle"></div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12, background: 'var(--info-bg)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <i className="ph-fill ph-drop pi" style={{ color: 'var(--info)' }}></i>
          </div>
          <div>
            <div className="h2">Watering {tree?.nickname}</div>
            <div className="caption">{tree?.species} · {tree?.street}</div>
          </div>
        </div>

        <div className="caption" style={{ marginBottom: 8 }}>HOW MUCH</div>
        <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
          {[2, 4, 8, 12].map(v => (
            <button key={v} onClick={() => setAmount(v)} style={{
              flex: 1, height: 56, border: '1px solid var(--hairline)',
              background: amount === v ? 'var(--primary-surface)' : 'var(--surface-card)',
              borderColor: amount === v ? 'var(--primary)' : 'var(--hairline)',
              borderRadius: 'var(--radius-md)',
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
              color: amount === v ? 'var(--primary-deep)' : 'var(--ink)',
              fontWeight: amount === v ? 700 : 500,
            }}>
              <span className="num" style={{ fontSize: 18 }}>{v}L</span>
              <span style={{ fontSize: 10 }}>
                {v === 2 ? 'Quick' : v === 4 ? 'Normal' : v === 8 ? 'Deep' : 'Storm'}
              </span>
            </button>
          ))}
        </div>

        <div className="caption" style={{ marginBottom: 8 }}>SOIL CONDITION</div>
        <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
          {[
            { id: 'moist', label: 'Moist', icon: 'ph-cloud' },
            { id: 'dry', label: 'Dry', icon: 'ph-sun' },
            { id: 'cracked', label: 'Cracked', icon: 'ph-warning' },
          ].map(s => (
            <button key={s.id} onClick={() => setSoil(s.id)} style={{
              flex: 1, height: 56, border: '1px solid var(--hairline)',
              background: soil === s.id ? 'var(--primary-surface)' : 'var(--surface-card)',
              borderColor: soil === s.id ? 'var(--primary)' : 'var(--hairline)',
              borderRadius: 'var(--radius-md)',
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 2,
              color: soil === s.id ? 'var(--primary-deep)' : 'var(--ink)',
            }}>
              <i className={`ph ${s.icon} pi-sm`}></i>
              <span style={{ fontSize: 12, fontWeight: 600 }}>{s.label}</span>
            </button>
          ))}
        </div>

        <div className="card" style={{ background: 'var(--info-bg)', boxShadow: 'none', padding: 12, marginBottom: 16, display: 'flex', gap: 10, alignItems: 'center' }}>
          <i className="ph-fill ph-cloud-rain pi" style={{ color: 'var(--info)' }}></i>
          <div className="body-sm" style={{ color: 'var(--info)' }}>Rain forecast Saturday — we'll skip your reminder that day.</div>
        </div>

        <div style={{ display: 'flex', gap: 8 }}>
          <button className="btn ghost" style={{ flex: 1 }} onClick={onClose}>Cancel</button>
          <button className="btn" style={{ flex: 2 }} onClick={() => onConfirm({ amount, soil })}>
            <i className="ph-fill ph-check pi-sm"></i> Log watering
          </button>
        </div>
      </div>
    </>
  );
}

// ─────────────────────────────────────────────────────────────
// PhotoCheckIn — full screen
// ─────────────────────────────────────────────────────────────
function PhotoCheckIn({ tree, onConfirm, onClose }) {
  const [step, setStep] = useState('frame'); // 'frame' | 'compare'
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'var(--surface-dark)', color: 'var(--on-dark)', zIndex: 40, display: 'flex', flexDirection: 'column' }} className="slide-in">
      {/* Top bar */}
      <div style={{ padding: '12px 12px', display: 'flex', alignItems: 'center', gap: 8 }}>
        <button onClick={onClose} style={{
          width: 40, height: 40, borderRadius: '50%', background: 'rgba(255,255,255,0.12)',
          border: 'none', color: 'white',
        }}>
          <i className="ph-bold ph-x pi-sm"></i>
        </button>
        <div style={{ flex: 1, textAlign: 'center' }}>
          <div className="h3" style={{ color: 'white', fontSize: 16 }}>Monthly photo</div>
          <div className="caption" style={{ color: 'rgba(255,255,255,0.6)' }}>{tree?.nickname} · {tree?.species}</div>
        </div>
        <div style={{ width: 40 }}></div>
      </div>

      {step === 'frame' && (
        <>
          {/* Camera viewfinder */}
          <div style={{ flex: 1, position: 'relative', overflow: 'hidden', margin: '0 12px', borderRadius: 20 }}>
            <CardScene color={tree?.color || '#9CC066'} dark>
              <div style={{ position: 'absolute', inset: 0, top: 20, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <TreeIllustration species={tree?.species || 'Sugar Maple'} color={tree?.color || '#9CC066'} size={280} />
              </div>
            </CardScene>
            {/* Ghost overlay of last photo */}
            <div style={{
              position: 'absolute', inset: 16,
              border: '2px dashed rgba(255,255,255,0.5)',
              borderRadius: 14,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              pointerEvents: 'none',
            }}>
              <div style={{ background: 'rgba(0,0,0,0.5)', color: 'white', padding: '4px 12px', borderRadius: 'var(--radius-full)', fontSize: 11, position: 'absolute', top: 12, left: '50%', transform: 'translateX(-50%)' }}>
                Match last month's frame
              </div>
            </div>
            {/* Reticle corners */}
            {[[16,16,'tl'],[16,16,'tr'],[16,16,'bl'],[16,16,'br']].map(([x,y,p], i) => (
              <div key={i} style={{
                position: 'absolute',
                [p[0] === 't' ? 'top' : 'bottom']: 24,
                [p[1] === 'l' ? 'left' : 'right']: 24,
                width: 24, height: 24,
                borderTop: p[0] === 't' ? '2px solid white' : 'none',
                borderBottom: p[0] === 'b' ? '2px solid white' : 'none',
                borderLeft: p[1] === 'l' ? '2px solid white' : 'none',
                borderRight: p[1] === 'r' ? '2px solid white' : 'none',
              }}></div>
            ))}
          </div>

          {/* Tip */}
          <div style={{ padding: '14px 24px', textAlign: 'center' }}>
            <div className="body-sm" style={{ color: 'rgba(255,255,255,0.85)' }}>
              <i className="ph-fill ph-lightbulb pi-sm" style={{ color: 'var(--accent)' }}></i> Stand at the curb, frame the whole tree. Side-by-side comes after.
            </div>
          </div>

          {/* Shutter */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-around', padding: '8px 32px 32px' }}>
            <button style={{ background: 'transparent', border: 'none', color: 'white' }}>
              <i className="ph ph-image-square pi-lg"></i>
            </button>
            <button onClick={() => setStep('compare')} style={{
              width: 76, height: 76, borderRadius: '50%',
              background: 'white', border: '4px solid rgba(255,255,255,0.4)',
              boxShadow: '0 0 0 4px white inset',
              cursor: 'pointer',
            }}></button>
            <button style={{ background: 'transparent', border: 'none', color: 'white' }}>
              <i className="ph ph-arrows-clockwise pi-lg"></i>
            </button>
          </div>
        </>
      )}

      {step === 'compare' && (
        <>
          <div style={{ flex: 1, padding: '0 16px' }}>
            <div className="caption" style={{ color: 'rgba(255,255,255,0.7)', textAlign: 'center', marginBottom: 12 }}>10 weeks of growth</div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, height: 360 }}>
              <div style={{ borderRadius: 14, overflow: 'hidden', position: 'relative' }}>
                <PhotoPlaceholder height="100%" species={tree?.species || 'Sugar Maple'} treeColor={tree?.color || '#9CC066'} date="Mar 12" />
                <div style={{ position: 'absolute', top: 8, left: 8, background: 'rgba(0,0,0,0.6)', color: 'white', padding: '2px 8px', borderRadius: 'var(--radius-full)', fontSize: 11 }}>First photo</div>
              </div>
              <div style={{ borderRadius: 14, overflow: 'hidden', position: 'relative' }}>
                <PhotoPlaceholder height="100%" species={tree?.species || 'Sugar Maple'} treeColor={tree?.color || '#9CC066'} date="Today" />
                <div style={{ position: 'absolute', top: 8, left: 8, background: 'var(--primary)', color: 'white', padding: '2px 8px', borderRadius: 'var(--radius-full)', fontSize: 11 }}>Today</div>
              </div>
            </div>

            {/* Growth stats */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10, marginTop: 16 }}>
              <div style={{ background: 'rgba(255,255,255,0.08)', borderRadius: 12, padding: 12 }}>
                <div className="caption" style={{ color: 'rgba(255,255,255,0.6)' }}>HEIGHT</div>
                <div className="num" style={{ color: 'white', fontSize: 20 }}>+24cm</div>
              </div>
              <div style={{ background: 'rgba(255,255,255,0.08)', borderRadius: 12, padding: 12 }}>
                <div className="caption" style={{ color: 'rgba(255,255,255,0.6)' }}>CANOPY</div>
                <div className="num" style={{ color: 'white', fontSize: 20 }}>+18%</div>
              </div>
              <div style={{ background: 'rgba(255,255,255,0.08)', borderRadius: 12, padding: 12 }}>
                <div className="caption" style={{ color: 'rgba(255,255,255,0.6)' }}>HEALTH</div>
                <div className="num" style={{ color: 'var(--profit)', fontSize: 20 }}>92</div>
              </div>
            </div>
          </div>
          <div style={{ padding: 16, display: 'flex', gap: 8 }}>
            <button className="btn ghost" style={{ flex: 1, color: 'white' }} onClick={() => setStep('frame')}>Retake</button>
            <button className="btn" style={{ flex: 2 }} onClick={onConfirm}><i className="ph-fill ph-check pi-sm"></i> Save check-in</button>
          </div>
        </>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// HealthLog — full screen form
// ─────────────────────────────────────────────────────────────
function HealthLog({ tree, onConfirm, onClose }) {
  const [leaves, setLeaves] = useState('healthy');
  const [trunk, setTrunk] = useState('intact');
  const [soil, setSoil] = useState('moist');
  const [notes, setNotes] = useState('');

  const score = (
    (leaves === 'healthy' ? 35 : leaves === 'yellowing' ? 22 : 8) +
    (trunk === 'intact' ? 35 : 12) +
    (soil === 'moist' ? 30 : soil === 'dry' ? 18 : 8)
  );

  return (
    <div style={{ position: 'absolute', inset: 0, background: 'var(--surface)', zIndex: 40, display: 'flex', flexDirection: 'column' }} className="slide-in">
      <TopBar
        title="Health check"
        subtitle={`${tree?.nickname} · ${tree?.species}`}
        leading={<IconButton icon="ph-x" weight="bold" onClick={onClose} />}
      />
      <div className="scroll-y" style={{ flex: 1, padding: '4px 16px' }}>
        <div className="card" style={{ marginBottom: 16, display: 'flex', gap: 12, alignItems: 'center' }}>
          <ProgressRing value={score} size={56} stroke={5}
            color={score > 75 ? 'var(--profit)' : score > 50 ? 'var(--warning)' : 'var(--error)'}
            label={<><span className="num" style={{ fontSize: 16 }}>{score}</span><span className="caption" style={{ fontSize: 9 }}>SCORE</span></>}
          />
          <div style={{ flex: 1 }}>
            <div className="h4">Live health score</div>
            <div className="caption" style={{ marginTop: 2 }}>Updates as you answer below. Stored to {tree?.nickname}'s log.</div>
          </div>
        </div>

        <FieldGroup label="Leaves" icon="ph-leaf"
          options={[
            { id: 'healthy', label: 'Healthy', tone: 'profit' },
            { id: 'yellowing', label: 'Yellowing', tone: 'warn' },
            { id: 'dropping', label: 'Dropping', tone: 'danger' },
          ]}
          value={leaves} onChange={setLeaves}
        />
        <FieldGroup label="Trunk" icon="ph-tree-evergreen"
          options={[
            { id: 'intact', label: 'Intact', tone: 'profit' },
            { id: 'damaged', label: 'Damaged', tone: 'danger' },
          ]}
          value={trunk} onChange={setTrunk}
        />
        <FieldGroup label="Soil" icon="ph-flower-tulip"
          options={[
            { id: 'moist', label: 'Moist', tone: 'profit' },
            { id: 'dry', label: 'Dry', tone: 'warn' },
            { id: 'cracked', label: 'Cracked', tone: 'danger' },
          ]}
          value={soil} onChange={setSoil}
        />

        <div style={{ marginTop: 16 }}>
          <div className="micro" style={{ marginBottom: 8, paddingLeft: 4 }}>NOTES</div>
          <textarea
            value={notes} onChange={(e) => setNotes(e.target.value)}
            placeholder="Anything else? Carved bark, hanging branches, weird insects…"
            style={{
              width: '100%', minHeight: 90, padding: 14,
              background: 'var(--surface-raised)', border: 'none',
              borderRadius: 'var(--radius-md)', font: 'inherit',
              fontSize: 14, color: 'var(--ink)', resize: 'none', outline: 'none',
            }}
          />
        </div>

        {(leaves !== 'healthy' || trunk !== 'intact' || soil === 'cracked') && (
          <div className="card" style={{ marginTop: 16, background: 'var(--warning-bg)', boxShadow: 'none', border: '1px solid var(--warning)', display: 'flex', gap: 12 }}>
            <i className="ph-fill ph-warning-circle pi" style={{ color: 'var(--warning)' }}></i>
            <div>
              <div className="h4" style={{ color: 'var(--warning)' }}>Flag for city forestry?</div>
              <div className="caption" style={{ color: 'var(--ink-secondary)', marginTop: 4 }}>We'll send a note to the urban forestry team with your photos and notes. Usually a response within 5 days.</div>
              <button className="btn sm" style={{ background: 'var(--warning)', marginTop: 10 }}>
                <i className="ph-bold ph-flag pi-sm"></i> Flag this tree
              </button>
            </div>
          </div>
        )}

        <div style={{ height: 80 }}></div>
      </div>
      <div style={{ padding: 16, borderTop: '1px solid var(--hairline)', background: 'var(--surface-card)' }}>
        <button className="btn block" onClick={onConfirm}><i className="ph-fill ph-check pi-sm"></i> Save report</button>
      </div>
    </div>
  );
}

function FieldGroup({ label, icon, options, value, onChange }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div className="micro" style={{ paddingLeft: 4, marginBottom: 8, display: 'flex', alignItems: 'center', gap: 6 }}>
        <i className={`ph ${icon} pi-sm`}></i> {label}
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        {options.map(o => {
          const sel = value === o.id;
          const accent = o.tone === 'profit' ? 'var(--profit)' : o.tone === 'warn' ? 'var(--warning)' : 'var(--error)';
          return (
            <button key={o.id} onClick={() => onChange(o.id)} style={{
              flex: 1, padding: '14px 8px',
              background: sel ? (o.tone === 'profit' ? 'var(--profit-surface)' : o.tone === 'warn' ? 'var(--warning-bg)' : 'var(--error-bg)') : 'var(--surface-card)',
              border: `1px solid ${sel ? accent : 'var(--hairline)'}`,
              borderRadius: 'var(--radius-md)',
              color: sel ? accent : 'var(--ink)',
              fontWeight: sel ? 700 : 500, fontSize: 13,
            }}>{o.label}</button>
          );
        })}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Certificate — adoption certificate modal
// ─────────────────────────────────────────────────────────────
function Certificate({ tree, onClose }) {
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'rgba(28, 36, 32, 0.65)', zIndex: 40, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', padding: 16 }}>
      <div style={{
        background: '#FBF6E9', borderRadius: 22, padding: 28,
        boxShadow: 'var(--elev-4)', width: '100%', maxWidth: 320,
        border: '2px solid var(--bark)',
        position: 'relative',
        animation: 'canopy-fade-up 280ms var(--ease-out)',
      }}>
        {/* Decorative corners */}
        {['tl','tr','bl','br'].map(c => (
          <div key={c} style={{
            position: 'absolute', width: 24, height: 24,
            [c[0] === 't' ? 'top' : 'bottom']: 12,
            [c[1] === 'l' ? 'left' : 'right']: 12,
            borderTop: c[0] === 't' ? '2px solid var(--bark)' : 'none',
            borderBottom: c[0] === 'b' ? '2px solid var(--bark)' : 'none',
            borderLeft: c[1] === 'l' ? '2px solid var(--bark)' : 'none',
            borderRight: c[1] === 'r' ? '2px solid var(--bark)' : 'none',
            opacity: 0.5,
          }}></div>
        ))}

        <div style={{ textAlign: 'center' }}>
          <div className="micro" style={{ color: 'var(--bark)', fontSize: 10, letterSpacing: 3 }}>CANOPY · OFFICIAL</div>
          <div className="h-display" style={{ fontSize: 22, marginTop: 6, color: 'var(--bark)' }}>Certificate of Adoption</div>
          <div style={{ height: 1, background: 'var(--bark)', opacity: 0.3, margin: '14px 24px' }}></div>
          <div className="body-sm" style={{ color: 'var(--ink-secondary)' }}>This certifies that</div>
          <div className="h-display" style={{ fontSize: 28, marginTop: 6, color: 'var(--bark)' }}>Ren Kobayashi</div>
          <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 8 }}>is the proud guardian of</div>
          <div style={{ margin: '12px 0' }}>
            <TreeIllustration species={tree?.species || 'Tulip Poplar'} color={tree?.color || '#9CC066'} size={120} />
          </div>
          <div className="h-display" style={{ fontSize: 26, color: 'var(--ink)' }}>{tree?.nickname}</div>
          <div className="body-sm" style={{ color: 'var(--ink-secondary)', fontStyle: 'italic', marginTop: 2 }}>
            {tree?.species} · <span style={{ fontStyle: 'normal' }}>{tree?.latin}</span>
          </div>
          <div className="caption" style={{ marginTop: 8 }}>Planted on {tree?.street}</div>
          <div style={{ height: 1, background: 'var(--bark)', opacity: 0.3, margin: '14px 24px' }}></div>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0 8px' }}>
            <div style={{ textAlign: 'left' }}>
              <div className="caption" style={{ fontSize: 10, color: 'var(--ink-tertiary)' }}>SINCE</div>
              <div className="body-sm" style={{ fontWeight: 600 }}>{tree?.adoptedDate || 'Mar 12, 2026'}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="caption" style={{ fontSize: 10, color: 'var(--ink-tertiary)' }}>GUARDIAN #</div>
              <div className="body-sm" style={{ fontWeight: 600, fontFamily: 'monospace' }}>CB-0440</div>
            </div>
          </div>
        </div>
      </div>
      <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
        <button className="btn secondary" onClick={onClose}><i className="ph-bold ph-x pi-sm"></i> Close</button>
        <button className="btn"><i className="ph-fill ph-export pi-sm"></i> Share</button>
        <button className="btn secondary"><i className="ph-bold ph-download-simple pi-sm"></i></button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// AdminView — forestry / city dashboard (mobile-friendly)
// ─────────────────────────────────────────────────────────────
function AdminView({ data, onClose }) {
  const [tab, setTab] = useState('overview');
  return (
    <div style={{ position: 'absolute', inset: 0, background: 'var(--surface)', zIndex: 40, display: 'flex', flexDirection: 'column' }} className="slide-in">
      <TopBar
        title="Forestry view"
        subtitle="Maple Heights district · admin"
        leading={<IconButton icon="ph-arrow-left" weight="bold" onClick={onClose} />}
        trailing={<IconButton icon="ph-export" onClick={() => {}} />}
      />

      {/* Sub tabs */}
      <div style={{ padding: '0 16px 12px', display: 'flex', gap: 4 }}>
        {[
          { id: 'overview', label: 'Overview' },
          { id: 'trees', label: 'Trees' },
          { id: 'upload', label: 'Plant list' },
        ].map(t => (
          <button key={t.id} onClick={() => setTab(t.id)} style={{
            padding: '8px 14px', border: 'none',
            background: tab === t.id ? 'var(--bark)' : 'transparent',
            color: tab === t.id ? 'white' : 'var(--ink-secondary)',
            borderRadius: 'var(--radius-full)', fontWeight: 600, fontSize: 13,
          }}>{t.label}</button>
        ))}
      </div>

      <div className="scroll-y" style={{ flex: 1 }}>
        {tab === 'overview' && <AdminOverview data={data} />}
        {tab === 'trees' && <AdminTrees data={data} />}
        {tab === 'upload' && <AdminUpload />}
      </div>
    </div>
  );
}

function AdminOverview({ data }) {
  const trees = data.ADMIN_TREES;
  const total = trees.length;
  const adopted = trees.filter(t => t.status === 'adopted').length;
  const available = trees.filter(t => t.status === 'available').length;
  const dead = trees.filter(t => t.status === 'dead').length;
  const adoptedPct = Math.round((adopted / total) * 100);
  return (
    <div className="fade-up" style={{ padding: '4px 16px 24px' }}>
      {/* KPI cards */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div className="card">
          <div className="micro">ADOPTION RATE</div>
          <div className="num-hero" style={{ fontSize: 32, color: 'var(--primary)' }}>{adoptedPct}%</div>
          <div className="caption" style={{ marginTop: 4 }}>{adopted} of {total} trees</div>
          <div style={{ height: 6, background: 'var(--surface-raised)', borderRadius: 3, marginTop: 10, overflow: 'hidden' }}>
            <div style={{ width: `${adoptedPct}%`, height: '100%', background: 'var(--primary)' }}></div>
          </div>
        </div>
        <div className="card">
          <div className="micro">SURVIVAL · 12mo</div>
          <div className="num-hero" style={{ fontSize: 32, color: 'var(--profit)' }}>89%</div>
          <div className="caption" style={{ marginTop: 4 }}>Up from 71% (pre-Canopy)</div>
          <div className="chip profit" style={{ marginTop: 10, height: 22 }}>
            <i className="ph-bold ph-trend-up pi-sm"></i> +18 pts
          </div>
        </div>
      </div>

      {/* District breakdown */}
      <SectionHeader title="By status" />
      <div style={{ padding: '0 0', marginBottom: 16 }}>
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          {[
            { label: 'Adopted · healthy', value: adopted - 1, color: 'var(--pin-healthy)' },
            { label: 'Adopted · attention', value: 1, color: 'var(--pin-attention)' },
            { label: 'Available', value: available, color: 'var(--pin-available)' },
            { label: 'Dead / removed', value: dead, color: 'var(--pin-risk)' },
          ].map((row, i, arr) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
              borderBottom: i < arr.length - 1 ? '1px solid var(--hairline-soft)' : 'none',
            }}>
              <span style={{ width: 10, height: 10, borderRadius: '50%', background: row.color, flexShrink: 0 }}></span>
              <span className="body-md" style={{ flex: 1 }}>{row.label}</span>
              <span className="num" style={{ fontSize: 15, fontWeight: 700 }}>{row.value}</span>
            </div>
          ))}
        </div>
      </div>

      {/* At-risk alerts */}
      <SectionHeader title="At risk · 2" action={<span className="caption">Last sync 9m ago</span>} />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        <AdminAlert tree={trees.find(t => t.health === 'attention')} severity="warn" message="Guardian reported yellowing leaves & dry soil · 3 days unattended" />
        <AdminAlert tree={trees.find(t => t.status === 'dead')} severity="danger" message="Guardian resigned · pending removal & replant" />
      </div>
    </div>
  );
}

function AdminAlert({ tree, severity, message }) {
  if (!tree) return null;
  const bg = severity === 'danger' ? 'var(--error-bg)' : 'var(--warning-bg)';
  const fg = severity === 'danger' ? 'var(--error)' : 'var(--warning)';
  return (
    <div className="card" style={{ background: bg, border: `1px solid ${fg}`, boxShadow: 'none', padding: 14 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 6 }}>
        <div>
          <span className="h4">{tree.code}</span>
          <span className="caption" style={{ marginLeft: 8 }}>{tree.species} · {tree.street}</span>
        </div>
        <span className="chip" style={{ background: fg, color: 'white', height: 22 }}>
          {severity === 'danger' ? 'Critical' : 'Action needed'}
        </span>
      </div>
      <div className="body-sm" style={{ color: 'var(--ink-secondary)' }}>{message}</div>
      <div style={{ display: 'flex', gap: 6, marginTop: 10 }}>
        <button className="btn sm secondary">View</button>
        <button className="btn sm secondary">Message guardian</button>
        <button className="btn sm secondary">Dispatch crew</button>
      </div>
    </div>
  );
}

function AdminTrees({ data }) {
  const [q, setQ] = useState('');
  const rows = data.ADMIN_TREES.filter(t =>
    !q || t.code.toLowerCase().includes(q.toLowerCase()) || t.species.toLowerCase().includes(q.toLowerCase()) || t.street.toLowerCase().includes(q.toLowerCase())
  );
  return (
    <div className="fade-up" style={{ padding: '4px 16px 24px' }}>
      <div style={{ position: 'relative', marginBottom: 12 }}>
        <input value={q} onChange={e => setQ(e.target.value)} placeholder="Search by code, species, street…" className="input" style={{ paddingLeft: 42 }} />
        <i className="ph ph-magnifying-glass pi-sm" style={{ position: 'absolute', left: 14, top: 16, color: 'var(--ink-tertiary)' }}></i>
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        {rows.map((t, i) => (
          <div key={t.id} style={{
            display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
            borderBottom: i < rows.length - 1 ? '1px solid var(--hairline-soft)' : 'none',
            background: t.status === 'dead' ? 'var(--error-bg)' : 'transparent',
          }}>
            <div style={{
              fontFamily: 'ui-monospace, monospace', fontSize: 11, fontWeight: 600,
              padding: '2px 6px', borderRadius: 4, background: 'var(--surface-raised)',
              color: 'var(--ink-secondary)', minWidth: 64, textAlign: 'center',
            }}>{t.code}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div className="h4" style={{ fontSize: 13 }}>{t.species}</div>
              <div className="caption">{t.street} · planted {t.planted}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, justifyContent: 'flex-end' }}>
                <HealthDot status={t.status === 'adopted' ? t.health : (t.status === 'dead' ? 'risk' : 'available')} size={7} />
                <span className="caption" style={{ fontWeight: 600 }}>
                  {t.status === 'adopted' ? t.guardian.split(' ')[0] : t.status === 'dead' ? 'Dead' : 'Open'}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function AdminUpload() {
  return (
    <div className="fade-up" style={{ padding: '4px 16px 24px' }}>
      <div className="card" style={{
        textAlign: 'center', padding: 32,
        border: '2px dashed var(--hairline-strong)', boxShadow: 'none',
      }}>
        <i className="ph-duotone ph-upload-simple pi" style={{ fontSize: 44, color: 'var(--bark)' }}></i>
        <div className="h3" style={{ marginTop: 10 }}>Upload planting CSV</div>
        <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 4 }}>
          Columns: <code style={{ fontFamily: 'monospace', fontSize: 12 }}>code, species, street, planted_at, lat, lng</code>
        </div>
        <button className="btn" style={{ marginTop: 16, background: 'var(--bark)' }}>
          <i className="ph-bold ph-upload pi-sm"></i> Choose CSV
        </button>
      </div>

      <SectionHeader title="Recent uploads" />
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        {[
          { name: 'spring-2026-plantings.csv', date: 'Apr 02', rows: 48, status: 'Imported' },
          { name: 'oakridge-replant.csv', date: 'Mar 18', rows: 12, status: 'Imported' },
          { name: 'fall-2025-final.csv', date: 'Oct 22', rows: 64, status: 'Imported' },
        ].map((f, i, arr) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '14px',
            borderBottom: i < arr.length - 1 ? '1px solid var(--hairline-soft)' : 'none',
          }}>
            <i className="ph-duotone ph-file-csv pi" style={{ fontSize: 28, color: 'var(--bark)' }}></i>
            <div style={{ flex: 1 }}>
              <div className="h4" style={{ fontSize: 13, fontFamily: 'monospace' }}>{f.name}</div>
              <div className="caption">{f.rows} rows · {f.date}</div>
            </div>
            <span className="chip profit"><i className="ph-bold ph-check pi-sm"></i> {f.status}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {
  WaterSheet, PhotoCheckIn, HealthLog, Certificate, AdminView, AdminOverview, AdminTrees, AdminUpload,
});
