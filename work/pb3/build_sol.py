import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pb3build
pb3build.build(out=sys.argv[1] if len(sys.argv)>1 else "work/build/PB3_sol.nes",
               shell_bin="work/pb3/bp1.bin")
