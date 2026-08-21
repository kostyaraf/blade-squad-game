"""Input scripts for the headless emulator.

PB3 boots into Power Blade 2's logos and title screen, then into PB3's own
stage list.  `script` mashes START through the logos, waits for the list to
come up, walks the cursor to one entry and starts it."""

MENU_FRAME = 1000               # the list is up and listening well before this


def script(entry=0, players=1, hero=0, play=(), start=MENU_FRAME, step=20):
    """`entry` is a line in PB3's stage list (0 = the first Power Blade
    stage), `players` 1 or 2, `hero` 0 = Power Blade, 1 = Solbrain."""
    L, f = [], 60
    for _ in range(7):                      # through the logos and the title
        L += [f'{f} START', f'{f + 6} -']; f += 40
    f = start
    up = 2 if players == 2 else (1 if hero else 0)
    for _ in range(up):                     # the cursor starts on the first stage
        L += [f'{f} UP', f'{f + 6} -']; f += step
    if up:
        L += [f'{f} RIGHT', f'{f + 6} -']; f += step
    for _ in range(up):
        L += [f'{f} DOWN', f'{f + 6} -']; f += step
    for _ in range(entry):
        L += [f'{f} DOWN', f'{f + 6} -']; f += step
    L += [f'{f + step} START', f'{f + step + 6} -']
    for at, keys in play:
        L.append(f'{at} {keys}')
    return '\n'.join(L) + '\n'


def launch_frame(entry=0, players=1, hero=0, start=MENU_FRAME, step=20):
    up = 2 if players == 2 else (1 if hero else 0)
    n = entry + 2 * up + (1 if up else 0)
    return start + (n + 1) * step
