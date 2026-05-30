// canopy-impact.jsx — Impact dashboard + Community feed + Leaderboard
// Two screens: Impact (with switchable views), and You (profile + settings + admin)

function ImpactScreen({ data, onOpenAdmin }) {
  const [tab, setTab] = useState('impact'); // 'impact' | 'community' | 'leaders'

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--surface)' }}>
      <TopBar title="Impact" subtitle="What your grove is doing" large
        trailing={<IconButton icon="ph-export" onClick={() => {}} />}
      />

      {/* Segmented tabs */}
      <div style={{ padding: '0 16px 12px' }}>
        <div style={{
          display: 'flex', background: 'var(--surface-raised)',
          borderRadius: 'var(--radius-full)', padding: 4, position: 'relative',
        }}>
          {[
            { id: 'impact', label: 'Mine' },
            { id: 'community', label: 'Feed' },
            { id: 'leaders', label: 'Leaders' },
          ].map(s => (
            <button key={s.id} onClick={() => setTab(s.id)} style={{
              flex: 1, border: 'none', padding: '8px 0',
              background: tab === s.id ? 'var(--surface-card)' : 'transparent',
              color: tab === s.id ? 'var(--ink)' : 'var(--ink-secondary)',
              fontWeight: 600, fontSize: 13,
              borderRadius: 'var(--radius-full)',
              boxShadow: tab === s.id ? 'var(--elev-1)' : 'none',
              transition: 'background 200ms',
            }}>{s.label}</button>
          ))}
        </div>
      </div>

      <div className="scroll-y" style={{ flex: 1 }}>
        {tab === 'impact' && <MyImpact data={data} onOpenAdmin={onOpenAdmin} />}
        {tab === 'community' && <CommunityFeed data={data} />}
        {tab === 'leaders' && <Leaderboard data={data} />}
      </div>
    </div>
  );
}

function MyImpact({ data, onOpenAdmin }) {
  return (
    <div className="fade-up" style={{ paddingBottom: 24 }}>
      {/* Hero stat */}
      <div style={{ padding: '4px 16px 16px' }}>
        <div style={{
          background: 'linear-gradient(135deg, var(--primary) 0%, var(--primary-deep) 100%)',
          color: 'var(--on-primary)', borderRadius: 'var(--radius-card)',
          padding: 24, position: 'relative', overflow: 'hidden',
        }}>
          {/* faint leaves */}
          <svg style={{ position: 'absolute', right: -20, top: -10, width: 180, height: 180, opacity: 0.18 }} viewBox="0 0 120 120">
            <circle cx="60" cy="56" r="36" fill="white" />
            <circle cx="44" cy="48" r="14" fill="white" />
            <circle cx="76" cy="48" r="14" fill="white" />
          </svg>
          <div className="micro" style={{ color: 'rgba(255,255,255,0.7)' }}>YOU'VE KEPT ALIVE</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginTop: 4 }}>
            <span className="num-hero" style={{ fontSize: 52, color: 'var(--on-primary)' }}>3</span>
            <span className="h2" style={{ color: 'rgba(255,255,255,0.8)' }}>trees, 68 days</span>
          </div>
          <div className="body-sm" style={{ marginTop: 10, opacity: 0.85, maxWidth: 280 }}>
            That's like taking <span style={{ fontWeight: 700 }}>148 mi</span> of city driving off the road this year. Keep going.
          </div>
        </div>
      </div>

      {/* Stat grid */}
      <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <ImpactStat icon="ph-tree" value="3" label="Adopted" accent="var(--primary)" />
        <ImpactStat icon="ph-flame" value="68" unit="d" label="Streak" accent="var(--accent)" />
        <ImpactStat icon="ph-drop" value="31" unit="L" label="Water given" accent="var(--info)" />
        <ImpactStat icon="ph-cloud" value="42" unit="kg" label="CO₂ absorbed" accent="var(--profit)" />
      </div>

      {/* Driving equivalents card */}
      <div style={{ padding: '16px 16px 8px' }}>
        <div className="card">
          <div className="micro">EQUIVALENT TO</div>
          <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 14 }}>
            <Equivalent icon="ph-car" label="Car miles offset" value="148 mi" />
            <Equivalent icon="ph-airplane" label="Coast-to-coast flight" value="6%" />
            <Equivalent icon="ph-bird" label="Birds welcomed home" value="~14" sub="Est. nesting & feeding" />
          </div>
        </div>
      </div>

      {/* Survival streak chart */}
      <SectionHeader title="Survival streak" />
      <div style={{ padding: '0 16px' }}>
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div>
              <div className="num-hero" style={{ fontSize: 32, color: 'var(--accent)' }}>68</div>
              <div className="caption" style={{ marginTop: 2 }}>consecutive days · all trees alive</div>
            </div>
            <span className="chip accent">
              <i className="ph-fill ph-flame pi-sm"></i> personal best
            </span>
          </div>
          {/* mini bar chart */}
          <div style={{ display: 'flex', gap: 3, alignItems: 'flex-end', height: 80, marginTop: 16 }}>
            {Array.from({ length: 30 }).map((_, i) => {
              const h = 20 + Math.abs(Math.sin(i * 0.7)) * 50 + (i / 30) * 12;
              return <div key={i} style={{
                flex: 1, height: h, borderRadius: 2,
                background: i > 25 ? 'var(--accent)' : 'var(--primary-muted)',
              }}></div>;
            })}
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6 }}>
            <span className="caption" style={{ fontSize: 10 }}>30 days ago</span>
            <span className="caption" style={{ fontSize: 10 }}>Today</span>
          </div>
        </div>
      </div>

      {/* Badges */}
      <SectionHeader title="Badges" action={<button style={{ border: 'none', background: 'transparent', color: 'var(--primary)', fontSize: 13, fontWeight: 600 }}>All 12</button>} />
      <div className="scroll-x" style={{ padding: '0 16px 4px', display: 'flex', gap: 10 }}>
        {data.BADGES.map(b => <BadgeChip key={b.id} badge={b} />)}
      </div>
    </div>
  );
}

function ImpactStat({ icon, value, unit, label, accent }) {
  return (
    <div className="card" style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10,
        background: accent + '22', position: 'relative',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <i className={`ph-bold ${icon} pi`} style={{ color: accent, fontSize: 20 }}></i>
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 3, marginTop: 2 }}>
        <span className="num" style={{ fontSize: 26, fontWeight: 700 }}>{value}</span>
        {unit && <span className="caption">{unit}</span>}
      </div>
      <div className="caption">{label}</div>
    </div>
  );
}

function Equivalent({ icon, label, value, sub }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
      <div style={{
        width: 40, height: 40, borderRadius: 10, background: 'var(--surface-raised)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <i className={`ph-duotone ${icon} pi`} style={{ color: 'var(--ink-secondary)' }}></i>
      </div>
      <div style={{ flex: 1 }}>
        <div className="h4" style={{ fontSize: 14 }}>{label}</div>
        {sub && <div className="caption" style={{ marginTop: 1 }}>{sub}</div>}
      </div>
      <div className="num" style={{ fontSize: 16, fontWeight: 700, color: 'var(--ink)' }}>{value}</div>
    </div>
  );
}

function BadgeChip({ badge }) {
  return (
    <div style={{
      flex: '0 0 auto', width: 110, padding: 12,
      background: badge.earned ? 'var(--surface-card)' : 'var(--surface-raised)',
      borderRadius: 'var(--radius-card)',
      border: badge.earned ? '1px solid var(--accent-light)' : '1px solid transparent',
      textAlign: 'center', boxShadow: badge.earned ? 'var(--elev-1)' : 'none',
      opacity: badge.earned ? 1 : 0.6,
    }}>
      <div style={{
        width: 48, height: 48, borderRadius: '50%', margin: '0 auto',
        background: badge.earned ? 'var(--accent-surface)' : 'var(--surface-overlay)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <i className={`ph-fill ${badge.icon} pi-lg`} style={{
          color: badge.earned ? 'var(--accent-deep)' : 'var(--ink-tertiary)',
        }}></i>
      </div>
      <div className="h4" style={{ fontSize: 12, marginTop: 8 }}>{badge.name}</div>
      <div className="caption" style={{ fontSize: 10, marginTop: 1 }}>
        {badge.earned ? badge.date : `${Math.round((badge.progress || 0) * 100)}%`}
      </div>
    </div>
  );
}

function CommunityFeed({ data }) {
  return (
    <div className="fade-up" style={{ padding: '4px 16px 24px', display: 'flex', flexDirection: 'column', gap: 12 }}>
      {data.FEED.map((event, i) => (
        <div key={event.id} className="card" style={{ display: 'flex', gap: 12, alignItems: 'flex-start', padding: 14 }}>
          <Avatar name={event.who} hue={(i * 73) % 360} you={event.who === 'You'} size={40} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="body-sm">
              <span style={{ fontWeight: 600 }}>{event.who}</span>
              <span style={{ color: 'var(--ink-secondary)' }}> {event.what} </span>
              <span style={{ fontWeight: 600, color: 'var(--primary)' }}>{event.tree}</span>
              <span style={{ color: 'var(--ink-secondary)' }}> · {event.species}</span>
            </div>
            <div className="caption" style={{ marginTop: 2 }}>{event.when}</div>
            {event.what === 'photographed' && (
              <div style={{ marginTop: 10 }}>
                <PhotoPlaceholder height={120} species={event.species} treeColor="#9CC066" />
              </div>
            )}
            {event.what === 'reported issue on' && (
              <div style={{ marginTop: 8 }}>
                <span className="chip warn"><i className="ph-bold ph-warning-circle pi-sm"></i> Soil cracked, leaves yellowing</span>
              </div>
            )}
            <div style={{ display: 'flex', gap: 14, marginTop: 10, color: 'var(--ink-tertiary)' }}>
              <button style={{ border: 'none', background: 'transparent', display: 'inline-flex', alignItems: 'center', gap: 4, color: 'inherit', padding: 0, fontSize: 12 }}>
                <i className="ph ph-hands-clapping pi-sm"></i> {((i * 11) % 23) + 2}
              </button>
              <button style={{ border: 'none', background: 'transparent', display: 'inline-flex', alignItems: 'center', gap: 4, color: 'inherit', padding: 0, fontSize: 12 }}>
                <i className="ph ph-chat-circle pi-sm"></i> {(i % 4) + 1}
              </button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function Leaderboard({ data }) {
  return (
    <div className="fade-up" style={{ padding: '4px 16px 24px' }}>
      <div className="card" style={{ marginBottom: 16 }}>
        <div className="micro">THIS MONTH · MAPLE HEIGHTS</div>
        <div className="h3" style={{ marginTop: 4 }}>Most active guardians</div>
        <div className="caption" style={{ marginTop: 4 }}>Ranked by trees adopted, water logs, and active streaks. Resets May 31.</div>
      </div>

      {/* Top 3 podium */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, alignItems: 'flex-end' }}>
        {[1, 0, 2].map(i => {
          const l = data.LEADERBOARD[i];
          const height = [80, 100, 64][i];
          const rankColor = ['var(--rank-1, #F2B544)', 'var(--rank-2, #B8BDB5)', 'var(--rank-3, #CD8A4A)'][i] || 'var(--ink-tertiary)';
          return (
            <div key={l.rank} style={{ flex: 1, textAlign: 'center' }}>
              <Avatar name={l.name} size={48} hue={i * 87} you={l.you} />
              <div className="h4" style={{ fontSize: 13, marginTop: 6 }}>{l.name.split(' ')[0]}</div>
              <div className="caption" style={{ fontSize: 11 }}>{l.streak}d · {l.trees} trees</div>
              <div style={{
                marginTop: 6, height,
                background: l.you ? 'var(--primary-surface)' : 'var(--surface-raised)',
                borderRadius: '12px 12px 0 0',
                position: 'relative',
                border: `1px solid ${l.you ? 'var(--primary)' : 'var(--hairline)'}`,
                borderBottom: 'none',
              }}>
                <div style={{
                  position: 'absolute', top: -10, left: '50%', transform: 'translateX(-50%)',
                  background: rankColor, color: 'white',
                  width: 24, height: 24, borderRadius: '50%',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontWeight: 700, fontSize: 12,
                }}>{l.rank}</div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Rest of list */}
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        {data.LEADERBOARD.slice(3).map((l, i) => (
          <div key={l.rank} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
            borderBottom: i < data.LEADERBOARD.length - 4 ? '1px solid var(--hairline-soft)' : 'none',
            background: l.you ? 'var(--primary-surface)' : 'transparent',
          }}>
            <span className="num" style={{ width: 22, fontWeight: 700, color: 'var(--ink-tertiary)', fontSize: 14 }}>{l.rank}</span>
            <Avatar name={l.name} size={36} hue={l.rank * 47} you={l.you} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div className="h4" style={{ fontSize: 14 }}>{l.name}</div>
              <div className="caption">{l.neighborhood}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="num" style={{ fontSize: 14, fontWeight: 700 }}>{l.streak}d</div>
              <div className="caption" style={{ fontSize: 10 }}>{l.trees} trees</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// YouScreen — profile / settings / admin toggle
// ─────────────────────────────────────────────────────────────
function YouScreen({ onOpenAdmin, onOpenOnboarding }) {
  return (
    <div className="scroll-y" style={{ height: '100%', background: 'var(--surface)' }}>
      <TopBar title="You" large
        trailing={<IconButton icon="ph-gear-six" onClick={() => {}} />}
      />

      {/* Profile card */}
      <div style={{ padding: '4px 16px 8px' }}>
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <Avatar name="Ren Kobayashi" size={64} you />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="h-display" style={{ fontSize: 22 }}>Ren Kobayashi</div>
            <div className="caption" style={{ marginTop: 1 }}>Maple Heights · she/her</div>
            <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
              <span className="chip primary"><i className="ph-fill ph-shield-check pi-sm"></i> Guardian since Mar '26</span>
            </div>
          </div>
        </div>
      </div>

      {/* Stats triad */}
      <div style={{ padding: '8px 16px', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 1, background: 'var(--surface-card)', borderRadius: 'var(--radius-card)', overflow: 'hidden' }}>
        <YouStat value="3" label="Trees" />
        <YouStat value="68d" label="Streak" />
        <YouStat value="#3" label="Block rank" />
      </div>

      {/* Settings list */}
      <div style={{ padding: '20px 16px 8px' }}>
        <div className="micro" style={{ paddingLeft: 4 }}>PREFERENCES</div>
      </div>
      <SettingsList items={[
        { icon: 'ph-bell', label: 'Notifications', value: 'Watering · weekly' },
        { icon: 'ph-cloud-rain', label: 'Weather source', value: 'OpenWeather' },
        { icon: 'ph-clock', label: 'Reminder time', value: '7:30 AM' },
        { icon: 'ph-map-pin', label: 'Home neighborhood', value: 'Maple Heights' },
      ]} />

      <div style={{ padding: '20px 16px 8px' }}>
        <div className="micro" style={{ paddingLeft: 4 }}>ACCOUNT</div>
      </div>
      <SettingsList items={[
        { icon: 'ph-question', label: 'Restart onboarding', onClick: onOpenOnboarding },
        { icon: 'ph-shield', label: 'Privacy & data' },
        { icon: 'ph-export', label: 'Export my logs' },
      ]} />

      {/* Forestry view */}
      <div style={{ padding: '20px 16px 24px' }}>
        <div className="card" style={{
          background: 'var(--bark-surface)', border: '1px solid var(--bark-light)',
          boxShadow: 'none', display: 'flex', gap: 14, alignItems: 'center',
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: 12,
            background: 'var(--bark)', color: 'white',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <i className="ph-fill ph-tree pi"></i>
          </div>
          <div style={{ flex: 1 }}>
            <div className="h4">Forestry view</div>
            <div className="caption" style={{ marginTop: 2 }}>City staff / campus admins</div>
          </div>
          <button onClick={onOpenAdmin} className="btn sm secondary">Open</button>
        </div>
      </div>
    </div>
  );
}

function YouStat({ value, label }) {
  return (
    <div style={{ padding: 14, textAlign: 'center', background: 'var(--surface-card)' }}>
      <div className="num" style={{ fontSize: 22, fontWeight: 700 }}>{value}</div>
      <div className="caption" style={{ marginTop: 2 }}>{label}</div>
    </div>
  );
}

function SettingsList({ items }) {
  return (
    <div style={{ padding: '0 16px' }}>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        {items.map((item, i) => (
          <button key={i} onClick={item.onClick} style={{
            width: '100%', border: 'none', background: 'transparent',
            display: 'flex', alignItems: 'center', gap: 12, padding: '14px',
            borderBottom: i < items.length - 1 ? '1px solid var(--hairline-soft)' : 'none',
            textAlign: 'left', cursor: 'pointer', color: 'var(--ink)',
          }}>
            <i className={`ph ${item.icon} pi-sm`} style={{ color: 'var(--ink-tertiary)', flexShrink: 0 }}></i>
            <span className="body-md" style={{ flex: 1 }}>{item.label}</span>
            {item.value && <span className="caption">{item.value}</span>}
            <i className="ph ph-caret-right pi-sm" style={{ color: 'var(--ink-tertiary)' }}></i>
          </button>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {
  ImpactScreen, MyImpact, CommunityFeed, Leaderboard,
  YouScreen, ImpactStat, BadgeChip, Equivalent, SettingsList,
});
