// canopy-grove.jsx — My Grove dashboard + Tree profile

function GroveScreen({ trees, onOpenTree, onWater, onAddTree, pinStyle = 'pin' }) {
  const adopted = trees.filter(t => t.status === 'adopted');
  const needsAction = adopted.filter(t => t.nextWaterIn <= 0 || t.health === 'attention' || t.health === 'risk');

  return (
    <div className="scroll-y" style={{ height: '100%', background: 'var(--surface)' }}>
      <TopBar
        title="Good morning, Ren"
        subtitle={`Guardian of ${adopted.length} trees · 68-day streak`}
        large
        trailing={
          <>
            <IconButton icon="ph-question" onClick={() => {}} />
            <IconButton icon="ph-bell" dot onClick={() => {}} />
          </>
        }
      />

      {/* Today block — needs action */}
      <div style={{ padding: '4px 16px 8px' }}>
        <div className="card" style={{
          background: needsAction.length > 0 ? 'var(--surface-card)' : 'var(--primary-surface)',
          padding: 20, position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <div className="micro" style={{ color: needsAction.length > 0 ? 'var(--warning)' : 'var(--primary)' }}>
                {needsAction.length > 0 ? 'TODAY' : 'ALL GOOD'}
              </div>
              <div className="h1" style={{ marginTop: 4, fontSize: 22 }}>
                {needsAction.length > 0
                  ? `${needsAction.length} tree${needsAction.length > 1 ? 's' : ''} need${needsAction.length > 1 ? '' : 's'} you`
                  : 'Your grove is thriving.'}
              </div>
              <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 6 }}>
                {needsAction.length > 0
                  ? 'Tap to log a watering — rain is forecast for Saturday, so we\'ll skip then.'
                  : 'Next check-in: Tuesday. Light rain is forecast tomorrow.'}
              </div>
            </div>
            <i className={`ph-duotone ${needsAction.length > 0 ? 'ph-drop' : 'ph-cloud-rain'} pi`} style={{ fontSize: 36, color: needsAction.length > 0 ? 'var(--info)' : 'var(--primary)', opacity: 0.7 }}></i>
          </div>
          {needsAction.length > 0 && (
            <div style={{ marginTop: 16, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              {needsAction.map(t => (
                <button key={t.id} onClick={() => onWater(t.id)} style={{
                  display: 'inline-flex', alignItems: 'center', gap: 8,
                  background: 'var(--primary)', color: 'var(--on-primary)',
                  border: 'none', padding: '8px 14px', borderRadius: 'var(--radius-full)',
                  fontWeight: 600, fontSize: 13,
                }}>
                  <i className="ph-fill ph-drop pi-sm"></i>
                  Water {t.nickname}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Quick stats */}
      <div style={{ padding: '8px 16px', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
        <QuickStat icon="ph-tree" value={adopted.length} label="Trees" />
        <QuickStat icon="ph-flame" value={68} label="Day streak" accent="var(--accent)" />
        <QuickStat icon="ph-drop" value={"31"} unit="L" label="Watered" accent="var(--info)" />
      </div>

      {/* My Grove section */}
      <div style={{ marginTop: 16 }}>
        <SectionHeader
          title="My Grove"
          action={
            <button onClick={onAddTree} style={{
              border: 'none', background: 'transparent', color: 'var(--primary)',
              display: 'inline-flex', alignItems: 'center', gap: 4, padding: '4px 8px',
              fontSize: 13, fontWeight: 600,
            }}>
              <i className="ph-bold ph-plus pi-sm"></i> Adopt more
            </button>
          }
        />
        <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {adopted.map(tree => (
            <TreeRow key={tree.id} tree={tree} onClick={() => onOpenTree(tree.id)} onWater={() => onWater(tree.id)} />
          ))}
          {adopted.length === 0 && (
            <div className="card-flat" style={{ textAlign: 'center', padding: 32, color: 'var(--ink-tertiary)' }}>
              <i className="ph-duotone ph-tree pi" style={{ fontSize: 44 }}></i>
              <div className="h3" style={{ marginTop: 8 }}>Your grove is empty</div>
              <div className="body-sm" style={{ marginTop: 4 }}>Head to Discover and adopt your first sapling.</div>
            </div>
          )}
        </div>
      </div>

      {/* Recently adopted in your area */}
      <div style={{ marginTop: 24 }}>
        <SectionHeader title="On your block" action={<button style={{ border: 'none', background: 'transparent', color: 'var(--primary)', fontSize: 13, fontWeight: 600 }}>See all</button>} />
        <div className="scroll-x" style={{ padding: '0 16px', display: 'flex', gap: 12, paddingBottom: 16 }}>
          {trees.filter(t => t.status === 'available').slice(0, 4).map(tree => (
            <button key={tree.id} onClick={() => onOpenTree(tree.id)} style={{
              flex: '0 0 auto', width: 132,
              border: 'none', background: 'var(--surface-card)',
              borderRadius: 'var(--radius-card)', padding: 12,
              boxShadow: 'var(--elev-1)', textAlign: 'left',
            }}>
              <div style={{ background: 'var(--primary-surface)', borderRadius: 'var(--radius-md)', height: 90, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <TreeIllustration species={tree.species} color={tree.color} size={80} />
              </div>
              <div className="h4" style={{ marginTop: 8, fontSize: 14 }}>{tree.nickname}</div>
              <div className="caption">{tree.distance} · {tree.species}</div>
            </button>
          ))}
        </div>
      </div>

      <div style={{ height: 24 }}></div>
    </div>
  );
}

function QuickStat({ icon, value, unit, label, accent = 'var(--primary)' }) {
  return (
    <div style={{
      background: 'var(--surface-card)', borderRadius: 'var(--radius-card)',
      padding: 12, boxShadow: 'var(--elev-1)',
    }}>
      <i className={`ph-duotone ${icon} pi`} style={{ fontSize: 20, color: accent }}></i>
      <div style={{ marginTop: 6, display: 'flex', alignItems: 'baseline', gap: 3 }}>
        <span className="num" style={{ fontSize: 22, fontWeight: 700 }}>{value}</span>
        {unit && <span className="caption">{unit}</span>}
      </div>
      <div className="caption" style={{ marginTop: 2 }}>{label}</div>
    </div>
  );
}

function TreeRow({ tree, onClick, onWater }) {
  const isOverdue = tree.nextWaterIn <= 0;
  return (
    <div className="card" onClick={onClick} style={{
      display: 'flex', gap: 14, alignItems: 'center',
      padding: '12px 14px', cursor: 'pointer',
    }}>
      <div style={{
        width: 64, height: 64, flexShrink: 0,
        borderRadius: 14, background: 'var(--primary-surface)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <TreeIllustration species={tree.species} color={tree.color} size={56} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
          <span className="h3" style={{ fontSize: 16, fontWeight: 600 }}>{tree.nickname}</span>
          <HealthDot status={tree.health} size={7} />
        </div>
        <div className="caption" style={{ marginTop: 1 }}>{tree.species} · {tree.street}</div>
        <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
          <span className="chip" style={{ height: 22, fontSize: 11, background: isOverdue ? 'var(--warning-bg)' : 'var(--surface-raised)', color: isOverdue ? 'var(--warning)' : 'var(--ink-secondary)' }}>
            <i className="ph ph-drop pi-sm" style={{ fontSize: 12 }}></i>
            {isOverdue ? `Overdue ${Math.abs(tree.nextWaterIn)}d` : `Water in ${tree.nextWaterIn}d`}
          </span>
          <span className="chip" style={{ height: 22, fontSize: 11 }}>
            <i className="ph ph-flame pi-sm" style={{ fontSize: 12 }}></i>{tree.waterStreak}d
          </span>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
        <ProgressRing
          value={tree.healthScore} size={44} stroke={4}
          color={tree.health === 'attention' ? 'var(--warning)' : 'var(--profit)'}
          label={<span className="num" style={{ fontSize: 12 }}>{tree.healthScore}</span>}
        />
        {isOverdue && (
          <button onClick={(e) => { e.stopPropagation(); onWater(); }} style={{
            border: 'none', background: 'var(--primary)', color: 'var(--on-primary)',
            borderRadius: 'var(--radius-full)', padding: '4px 10px', fontSize: 11, fontWeight: 600,
          }}>Water</button>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// TreeProfile — full detail page for a single tree
// ─────────────────────────────────────────────────────────────
function TreeProfile({ tree, onBack, onWater, onPhoto, onHealth, onCertificate, onAdopt }) {
  if (!tree) return null;
  const isMine = tree.status === 'adopted';

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--surface)' }} className="slide-in">
      {/* Hero */}
      <div style={{ flex: '0 0 auto', position: 'relative', height: 280 }}>
        <CardScene color={tree.color}>
          <div style={{ position: 'absolute', inset: 0, top: 30, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <TreeIllustration species={tree.species} color={tree.color} size={220} />
          </div>
        </CardScene>
        {/* Back button overlay */}
        <div style={{ position: 'absolute', top: 8, left: 8, right: 8, display: 'flex', justifyContent: 'space-between' }}>
          <IconButton icon="ph-arrow-left" weight="bold" onClick={onBack} />
          <div style={{ display: 'flex', gap: 4 }}>
            <IconButton icon="ph-export" onClick={() => {}} />
            {isMine && <IconButton icon="ph-dots-three" weight="bold" onClick={() => {}} />}
          </div>
        </div>
        {/* Status chip */}
        <div style={{ position: 'absolute', top: 16, left: '50%', transform: 'translateX(-50%)' }}>
          {isMine ? <HealthChip status={tree.health} /> : <span className="chip" style={{ background: 'rgba(255,255,255,0.85)' }}><HealthDot status="available" size={6} /> Available</span>}
        </div>
      </div>

      {/* Scrollable body */}
      <div className="scroll-y" style={{ flex: 1 }}>
        <div style={{ padding: '20px 16px 12px' }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 12 }}>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div className="h-display" style={{ fontSize: 32 }}>{tree.nickname}</div>
              <div className="body-md" style={{ color: 'var(--ink-secondary)', marginTop: 2 }}>
                {tree.species} · <span style={{ fontStyle: 'italic' }}>{tree.latin}</span>
              </div>
            </div>
            {isMine && (
              <ProgressRing
                value={tree.healthScore} size={56} stroke={5}
                color={tree.health === 'attention' ? 'var(--warning)' : 'var(--profit)'}
                label={<>
                  <span className="num" style={{ fontSize: 15 }}>{tree.healthScore}</span>
                  <span className="caption" style={{ fontSize: 9, marginTop: -2 }}>HEALTH</span>
                </>}
              />
            )}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 8, color: 'var(--ink-tertiary)' }}>
            <i className="ph ph-map-pin pi-sm"></i>
            <span className="body-sm">{tree.street} · {tree.distance} away</span>
            <button style={{ marginLeft: 'auto', border: 'none', background: 'var(--primary-surface)', color: 'var(--primary)', padding: '4px 10px', borderRadius: 'var(--radius-full)', fontSize: 12, fontWeight: 600 }}>
              <i className="ph-bold ph-navigation-arrow pi-sm"></i> Navigate
            </button>
          </div>

          <div className="body-md" style={{ color: 'var(--ink-secondary)', marginTop: 14, textWrap: 'pretty', fontStyle: 'italic' }}>
            "{tree.personality}"
          </div>
        </div>

        {/* Action row */}
        {isMine ? (
          <div style={{ padding: '8px 16px', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
            <ActionTile icon="ph-drop" label="Water" onClick={onWater} primary />
            <ActionTile icon="ph-camera" label="Photo" onClick={onPhoto} />
            <ActionTile icon="ph-clipboard-text" label="Health" onClick={onHealth} />
            <ActionTile icon="ph-certificate" label="Cert" onClick={onCertificate} />
          </div>
        ) : (
          <div style={{ padding: '8px 16px' }}>
            <button className="btn block" onClick={onAdopt}>
              <i className="ph-fill ph-heart pi-sm"></i> Adopt {tree.nickname}
            </button>
          </div>
        )}

        {/* Stats grid */}
        <div style={{ padding: '16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <FactCard label="Age" value={tree.age} icon="ph-calendar-blank" />
          <FactCard label="Height" value={tree.height} icon="ph-ruler" />
          <FactCard label="Water" value={tree.waterNeed} icon="ph-drop" />
          <FactCard label="Light" value={tree.light} icon="ph-sun" />
        </div>

        {isMine && (
          <>
            {/* Watering schedule */}
            <SectionHeader title="Watering" />
            <div style={{ padding: '0 16px' }}>
              <div className="card">
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div>
                    <div className="caption">Last watered</div>
                    <div className="h3" style={{ marginTop: 2 }}>{tree.lastWatered}</div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <div className="caption">Next due</div>
                    <div className="h3" style={{ marginTop: 2, color: tree.nextWaterIn <= 0 ? 'var(--warning)' : 'var(--ink)' }}>
                      {tree.nextWaterIn <= 0 ? `Overdue ${Math.abs(tree.nextWaterIn)}d` : `In ${tree.nextWaterIn}d`}
                    </div>
                  </div>
                </div>
                {/* Weekly schedule strip */}
                <div style={{ marginTop: 14, display: 'flex', gap: 6 }}>
                  {['M','T','W','T','F','S','S'].map((d, i) => {
                    const isToday = i === 3;
                    const isRain = i === 5;
                    const isWatered = i < 3 && i % 2 === 0;
                    return (
                      <div key={i} style={{
                        flex: 1, height: 56, borderRadius: 10,
                        background: isWatered ? 'var(--primary-surface)' : isRain ? 'var(--info-bg)' : 'var(--surface-raised)',
                        border: isToday ? '1.5px solid var(--primary)' : '1px solid transparent',
                        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                      }}>
                        <span className="micro" style={{ fontSize: 10 }}>{d}</span>
                        <i className={`ph ${isWatered ? 'ph-fill ph-drop' : isRain ? 'ph ph-cloud-rain' : ''} pi-sm`} style={{
                          color: isWatered ? 'var(--primary)' : isRain ? 'var(--info)' : 'transparent',
                          marginTop: 4,
                        }}></i>
                      </div>
                    );
                  })}
                </div>
                <div className="caption" style={{ marginTop: 10 }}>
                  <i className="ph-fill ph-cloud-rain pi-sm" style={{ color: 'var(--info)' }}></i> Rain forecast Saturday — we'll skip that day.
                </div>
              </div>
            </div>

            {/* Photo timeline */}
            <SectionHeader title="Growth timeline" action={<button onClick={onPhoto} style={{ border: 'none', background: 'transparent', color: 'var(--primary)', fontSize: 13, fontWeight: 600 }}><i className="ph-bold ph-plus pi-sm"></i> Add photo</button>} />
            <div className="scroll-x" style={{ padding: '0 16px', display: 'flex', gap: 8, paddingBottom: 4 }}>
              {['Mar 12', 'Apr 02', 'Apr 22', 'May 18'].map((date, i) => (
                <div key={date} style={{ flex: '0 0 auto', width: 124 }}>
                  <PhotoPlaceholder height={150} treeColor={tree.color} species={tree.species} date={date} />
                  <div className="caption" style={{ marginTop: 4, textAlign: 'center' }}>{i === 0 ? 'First photo' : `+${[20, 41, 67][i-1] || 0}d`}</div>
                </div>
              ))}
            </div>

            {/* Health log */}
            <SectionHeader title="Recent reports" action={<button onClick={onHealth} style={{ border: 'none', background: 'transparent', color: 'var(--primary)', fontSize: 13, fontWeight: 600 }}>Log</button>} />
            <div style={{ padding: '0 16px 32px', display: 'flex', flexDirection: 'column', gap: 8 }}>
              <LogRow icon="ph-drop" iconColor="var(--info)" title="Watered · 4L" sub="2 days ago · Soil was dry" />
              <LogRow icon="ph-camera" iconColor="var(--accent)" title="Photo check-in" sub="Apr 22 · 4 photos in timeline" />
              <LogRow icon="ph-leaf" iconColor="var(--profit)" title="Health logged" sub="Apr 18 · Leaves healthy, soil moist" />
              <LogRow icon="ph-warning-circle" iconColor="var(--warning)" title="Mild stress noted" sub="Apr 02 · Leaves yellowing slightly · resolved" />
            </div>
          </>
        )}

        {!isMine && (
          <>
            <div style={{ padding: '0 16px 24px' }}>
              <div className="card" style={{ background: 'var(--accent-surface)', border: '1px solid var(--accent-light)', boxShadow: 'none' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <i className="ph-duotone ph-info pi" style={{ fontSize: 28, color: 'var(--accent-deep)' }}></i>
                  <div>
                    <div className="h4">What being a guardian looks like</div>
                    <div className="body-sm" style={{ color: 'var(--ink-secondary)', marginTop: 2 }}>
                      Check in monthly with a photo. Water every 3 days in summer. Report damage. That's it.
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

function ActionTile({ icon, label, onClick, primary = false }) {
  return (
    <button onClick={onClick} style={{
      border: 'none',
      background: primary ? 'var(--primary)' : 'var(--surface-card)',
      color: primary ? 'var(--on-primary)' : 'var(--ink)',
      borderRadius: 'var(--radius-card)', padding: '14px 8px',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      boxShadow: primary ? 'var(--elev-2)' : 'var(--elev-1)',
    }}>
      <i className={`ph-bold ${icon} pi`}></i>
      <span style={{ fontSize: 12, fontWeight: 600 }}>{label}</span>
    </button>
  );
}

function FactCard({ label, value, icon }) {
  return (
    <div style={{ background: 'var(--surface-card)', borderRadius: 'var(--radius-card)', padding: 14, boxShadow: 'var(--elev-1)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <i className={`ph ${icon} pi-sm`} style={{ color: 'var(--ink-tertiary)' }}></i>
        <span className="caption">{label}</span>
      </div>
      <div className="h4" style={{ marginTop: 6 }}>{value}</div>
    </div>
  );
}

function LogRow({ icon, iconColor, title, sub }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: 12, background: 'var(--surface-card)', borderRadius: 'var(--radius-md)',
      border: '1px solid var(--hairline-soft)',
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: '50%',
        background: 'var(--surface-raised)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <i className={`ph-bold ${icon} pi-sm`} style={{ color: iconColor }}></i>
      </div>
      <div style={{ flex: 1 }}>
        <div className="h4" style={{ fontSize: 14 }}>{title}</div>
        <div className="caption" style={{ marginTop: 1 }}>{sub}</div>
      </div>
    </div>
  );
}

Object.assign(window, { GroveScreen, QuickStat, TreeRow, TreeProfile, ActionTile, FactCard, LogRow });
