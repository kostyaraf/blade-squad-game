"""Точные ускорения таймеров APU для интерпретатора Godot 3 на Switch."""
from pathlib import Path
from array import array
import re
import sys


def optimize(project: Path):
    # GF(2): xorshift-переходы кольца для 1, 2, 4, 8, 16, 32 тактов.
    table = array('H')
    for tap in [1, 6]:
        jump = [(n >> 1) | (((n ^ (n >> tap)) & 1) << 14) for n in range(32768)]
        for _power in range(6):
            table.extend(jump)
            jump = [jump[jump[n]] for n in range(32768)]
    if sys.byteorder != 'little':
        table.byteswap()
    (project / 'data/switch-noise-jumps.bin').write_bytes(table.tobytes())
    p = project / 'src/snd_chip.gd'
    s = p.read_text()
    s = s.replace('var _left = 0', 'var _noise_jumps = NXCompat.get_file_as_bytes("res://data/switch-noise-jumps.bin")\nvar _left = 0')
    old = '''\tfor _i in _fires:
\t\tvar b: int = (n_shift ^ (n_shift >> 6 if n_mode != 0 else n_shift >> 1)) & 1
\t\tn_shift = (n_shift >> 1) | (b << 14)'''
    new = '''\tvar shifts = _fires
\tvar power = 0
\twhile shifts > 0:
\t\tif (shifts & 1) != 0:
\t\t\tvar off = (n_mode * 6 + power) * 65536 + n_shift * 2
\t\t\tn_shift = int(_noise_jumps[off]) | (int(_noise_jumps[off + 1]) << 8)
\t\tshifts >>= 1
\t\tpower += 1'''
    assert old in s
    s = s.replace(old, new)
    start = s.index('\tfor _i in df:')
    end = s.index('\n\t# the two squares', start)
    original = s[start:end]
    # Нет входящих байтов: только сдвиг восьмибитного регистра и счётчик битов.
    s = s[:start] + '''\tif d_silence != 0 and d_full == 0 and d_left == 0:
\t\td_sr = 0 if df >= 8 else d_sr >> df
\t\td_bits = ((d_bits - 1 - df) % 8 + 8) % 8 + 1
\telse:
''' + '\n'.join('\t' + line if line else '' for line in original.split('\n')) + s[end:]
    # Между событиями кадра достаточно вычитать уже вычисленную дистанцию.
    s = s.replace('func run(n: int) -> void:\n\twhile n > 0:', 'func run(n: int) -> void:\n\tvar until_event = _to_event()\n\twhile n > 0:')
    s = s.replace('if reset_delay > 0 or _event_next():', 'if reset_delay > 0 or until_event == 0:')
    s = s.replace('\t\t\tn -= 1\n\t\t\tcontinue', '\t\t\tn -= 1\n\t\t\tuntil_event = _to_event()\n\t\t\tcontinue')
    s = s.replace('\t\tvar f = _to_event()', '\t\tvar f = until_event')
    s = s.replace('\t\tctr += k\n', '\t\tctr += k\n\t\tuntil_event -= k\n')
    # Убираем тысячи вызовов мелких функций в интерпретаторе за кадр.
    timers_start = s.index('func _timers(k: int) -> void:')
    timers_end = s.index('\n\n# ---', timers_start)
    timers = s[timers_start:timers_end].split('\n', 1)[1]
    adv_call = re.compile(r'(?m)^(\t*)_adv\(([^,]+), ([^,]+), ([^)]+)\)$')
    counter = [0]
    def inline_adv(m):
        counter[0] += 1
        tag = '_nx_adv' + str(counter[0])
        indent = m[1]
        c, period, count = m[2], m[3], m[4]
        lines = [f'var {tag}_c: int = {c}', f'var {tag}_p: int = {period}',
                 f'var {tag}_k: int = {count}', f'if {tag}_k <= {tag}_c:',
                 f'\t_left = {tag}_c - {tag}_k', '\t_fires = 0', 'else:',
                 f'\tvar {tag}_r: int = {tag}_k - {tag}_c - 1',
                 f'\t_fires = 1 + {tag}_r / ({tag}_p + 1)',
                 f'\t_left = {tag}_p - ({tag}_r % ({tag}_p + 1))']
        return '\n'.join(indent + line for line in lines)
    timers = adv_call.sub(inline_adv, timers)
    local_vars = re.findall(r'\bvar (\w+)', timers)
    def timer_inline(arg, prefix, indent):
        body = re.sub(r'\bk\b', arg, timers)
        for name in sorted(set(local_vars), key=len, reverse=True):
            body = re.sub(r'\b' + name + r'\b', prefix + name, body)
        return '\n'.join(indent + line[1:] if line.startswith('\t') else line
                         for line in body.rstrip().split('\n'))
    start = s.index('func run(n: int) -> void:')
    run = s[start:]
    run = run.replace('\t\t\t_timers(1)', timer_inline('1', '_event_', '\t\t\t'))
    run = run.replace('\t\t_timers(k)', timer_inline('k', '_burst_', '\t\t'))
    # Громкость меняется только при записи регистров и событиях кадра.
    amps = []
    for i in range(2):
        target = f'(p_period[{i}] - (p_period[{i}] >> sw_shift[{i}]) - {1 if i == 0 else 0} if sw_negate[{i}] != 0 else p_period[{i}] + (p_period[{i}] >> sw_shift[{i}]))'
        amps.append(f'_amp{i} = (env_vol[{i}] if env_const[{i}] != 0 else env_decay[{i}]) if length[{i}] != 0 and p_period[{i}] >= 8 and {target} <= 0x7FF else 0')
    amps.append('_ampn = (env_vol[3] if env_const[3] != 0 else env_decay[3]) if length[3] != 0 else 0')
    init = '\n'.join('\tvar ' + line for line in amps)
    run = run.replace('\tvar until_event = _to_event()', init + '\n\tvar _pulse_mix = NXState.SndChip__pulse_mix\n\tvar _tnd_mix = NXState.SndChip__tnd_mix\n\tvar until_event = _to_event()')
    run = run.replace('\t\t\t_frame_one()', '\t\t\t_frame_one()\n' + '\n'.join('\t\t\t' + line for line in amps))
    emit = s[s.index('func _emit() -> void:'):s.index('\n\n# ---', s.index('func _emit() -> void:'))].split('\n', 1)[1].rstrip()
    emit = emit.replace('NXState.SndChip__pulse_mix', '_pulse_mix').replace('NXState.SndChip__tnd_mix', '_tnd_mix')
    emit = emit.replace('_pulse_out(0) + _pulse_out(1)', '_amp0 * DUTY[p_duty[0]][p_seq[0]] + _amp1 * DUTY[p_duty[1]][p_seq[1]]')
    emit = emit.replace('_noise_out()', '_ampn * (1 - (n_shift & 1))')
    for indent, prefix in [('\t\t\t\t', '_event_mix_'), ('\t\t\t', '_burst_mix_')]:
        body = emit
        for name in ['v', 's']:
            body = re.sub(r'\b' + name + r'\b', prefix + name, body)
        body = '\n'.join(indent + line[1:] for line in body.split('\n'))
        run = run.replace(indent + '_emit()', body)
    s = s[:start] + run
    p.write_text(s)
    play = project / 'src/snd_play.gd'
    text = play.read_text().replace('\t\tvar v = float(NXCompat.decode_s16(wave, i)) / 32768.0',
        '\t\tvar bits: int = int(wave[i]) | (int(wave[i + 1]) << 8)\n\t\tvar v = float(bits - 65536 if bits >= 32768 else bits) / 32768.0')
    play.write_text(text)
