"""Parallel rollout search (input-only). Usage: orch.py cfg.json
cfg: entry, waypoints, prefix(optional), goal_entry, length, rollouts, workers, out."""
import json, subprocess, sys, os, random, time, pathlib
HERE = pathlib.Path(__file__).resolve().parent
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = '/Users/hropl/pr/mypr/PB3-wt/nova-sol/game'


def ticks(steps):
    return sum(int(s[0]) for s in steps)


def run_batch(cfg, prefix, seed0):
    procs = []
    for k in range(min(2, cfg.get('workers', 2))):  # at most 2 Godot at once (BRIEF)
        c = dict(cfg)
        c['prefix'] = prefix
        c['seed'] = seed0 + k
        c['out'] = str(HERE / f'w_{cfg["name"]}_{k}.json')
        p = HERE / f'wcfg_{cfg["name"]}_{k}.json'
        p.write_text(json.dumps(c))
        env = dict(os.environ, WORKER_CFG=str(p))
        procs.append((subprocess.Popen([GODOT, '--headless', '--path', GAME, '--script', str(HERE / 'worker.gd')],
                                       env=env, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE), c['out']))
    res = []
    for pr, out in procs:
        _, err = pr.communicate()
        if b'SCRIPT ERROR' in err:
            print('WORKER SCRIPT ERROR', err.decode()[-800:])
        try:
            res += json.load(open(out))
        except Exception as e:
            print('worker failed', e)
    return res


def main():
    cfg = json.load(open(sys.argv[1]))
    cfg.setdefault('name', pathlib.Path(sys.argv[1]).stem)
    out = pathlib.Path(cfg['out'])
    if out.exists() and cfg.get('resume', True):
        steps = json.load(open(out))['steps']
    else:
        steps = list(cfg.get('prefix', []))
    commits = [len(steps)]
    seed = cfg.get('seed', 1000)
    fails = 0
    stall = 0
    last_score = -1e18
    frac = cfg.get('commit', 0.5)
    t_start = time.time()
    while True:
        res = run_batch(cfg, steps, seed)
        seed += 100
        if not res:
            print('no results'); return
        best = max(res, key=lambda r: r['score'])
        alive = sum(1 for r in res if not r['dead'])
        if best['won']:
            steps = steps + best['seg']
            json.dump({'entry': cfg['entry'], 'steps': steps, 'won': True}, open(out, 'w'))
            print('WON', ticks(steps), best['desc'], flush=True)
            return
        if best['dead']:
            fails += 1
            back = min(fails, len(commits) - 1)
            if back > 0:
                n = commits[-1 - back]
                commits = commits[:len(commits) - back]
                steps = steps[:n]
            print(f'ALL DEAD -> back {back} to {ticks(steps)} ticks', flush=True)
            if fails > cfg.get('max_fails', 12):
                print('GIVE UP'); return
            continue
        if best['score'] <= last_score + cfg.get('min_gain', 1) and stall < cfg.get('stall_tries', 3):
            stall += 1
            print(f'no gain ({best["score"]:.0f} <= {last_score:.0f}), resample {stall}', flush=True)
            continue
        if stall >= cfg.get('stall_tries', 3) and best['score'] <= last_score + cfg.get('min_gain', 1):
            stall = 0
            if len(commits) > 1:
                commits.pop(); steps = steps[:commits[-1]]
                last_score = -1e18
                print(f'stalled -> back to {ticks(steps)}', flush=True)
                continue
        stall = 0
        last_score = best['score'] - cfg.get('slack', 300)
        fails = max(0, fails - 1)
        # commit the first part of the best rollout, up to the best intermediate mark
        seg = best['seg']
        marks = best['marks']
        cut = max(2, int(len(seg) * frac))
        cut -= cut % 2
        steps = steps + seg[:cut]
        commits.append(len(steps))
        json.dump({'entry': cfg['entry'], 'steps': steps, 'won': False}, open(out, 'w'))
        print(f'[{int(time.time()-t_start)}s] commit {ticks(steps)} ticks alive {alive}/{len(res)} best {best["score"]:.0f} {best["desc"]}', flush=True)
        if ticks(steps) > cfg.get('max_ticks', 30000):
            print('TICK LIMIT'); return


if __name__ == '__main__':
    main()
