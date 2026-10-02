#!/usr/bin/env python3
"""Compare $AED9 OAM with original NES execution, then PB3 integration fixtures."""
import json
import pathlib
import struct
import subprocess
import sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import verify_sol_player as V
import sol_probe as P


def records(path):
    data = pathlib.Path(path).read_bytes()
    out = []
    for at in range(0, len(data), 2056):
        chunk = data[at:at+2056]
        if len(chunk) != 2056:
            raise RuntimeError('Incomplete RAM capture')
        frame, pc, bank = struct.unpack('<IHH', chunk[:8])
        if bank == 3:
            out.append((frame, chunk[8:]))
    return out


def main():
    scratch = P.scratch('hatch-render')
    try:
        state = V.stand(scratch, 's0', 0, None)
        cases = []
        coverage = set()
        for face in [0, 128]:
            before, after = [str(pathlib.Path(scratch)/n) for n in ['before.bin','after.bin']]
            first = V.BASE + 2
            slot = 5
            # One real native child, in an isolated slot; no ROM code changes.
            seed = {0x600+slot: 0xC0, 0x650+slot: 14, 0x660+slot: 0xB2,
                    0x670+slot: 1, 0x680+slot: face, 0x6E0+slot: 255,
                    0x6F0+slot: 1, 0xA0+slot: 0, 0xB0+slot: 25,
                    0xC0+slot: 0, 0xD0+slot: 20}
            for base in [0x610,0x620,0x630,0x640,0x690,0x6A0,0x6B0,0x6C0,0x6D0]:
                seed[base+slot] = 0
            cmd = P.emu('-loadstate',state,'-frames',str(first+112),
                        '-ramat',before+'@AED9','-ramat',after+'@AF11')
            for addr,val in seed.items():
                cmd += ['-poke',f'{addr:04X}={val:02X}@{first}']
            subprocess.run(cmd,check=True,capture_output=True,timeout=60)
            pre,post = records(before),records(after)
            if len(pre)!=len(post) or len(pre)<40:
                raise RuntimeError(f'Insufficient paired calls: {len(pre)}/{len(post)}')
            for (f,m),(g,n) in zip(pre,post):
                if f!=g: raise RuntimeError('Capture frames differ')
                kind=m[0x650+slot]&63
                if kind not in [12,14]: raise RuntimeError('Unexpected caller')
                phase=255 if kind==14 else m[12]
                coverage.add((face,kind))
                cases.append(dict(frame=f,face=m[0x680+slot],phase=phase,
                    x=m[0x5C]|m[0x5D]<<8,y=m[0x5E]|m[0x5F]<<8,
                    before=list(m[0x200:0x300]),after=list(n[0x200:0x300]),
                    cursors=list(m[0x6A:0x6E]),want=list(n[0x6A:0x6E]),
                    banks=list(m[0x42:0x46]),want_banks=list(n[0x42:0x46])))
        if len(coverage)!=4: raise RuntimeError(f'Missing phase/facing coverage {coverage}')
        oracle=pathlib.Path(scratch)/'oracle.json'
        oracle.write_text(json.dumps(cases))
        print(f'NES: {len(cases)} calls, both facings and falling/hovering',flush=True)
        result=subprocess.run([V.GODOT,'--headless','--path',V.GAME,'--script',
            'res://tests/pb3_hatch_render_test.gd','--','--oracle='+str(oracle)],
            capture_output=True,text=True,timeout=120)
        print(result.stdout,end='');print(result.stderr,end='')
        bad=int(result.returncode!=0 or 'ERROR:' in result.stderr or 'FAIL:' in result.stdout
                or 'hatch rendering checks failed' not in result.stdout)
        print(f'{bad} of 1 hatch rendering suites differ')
        return bad
    finally:
        P.sweep(scratch)

if __name__=='__main__':
    raise SystemExit(main())
