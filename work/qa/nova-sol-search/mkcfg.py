import json,sys
# mkcfg.py name entry goal src_replay_dir t0 t1 step [prefix_out.json]
name,entry,goal,src,t0,t1,step=sys.argv[1:8]
entry,goal,t0,t1,step=map(int,(entry,goal,t0,t1,step))
S='/private/tmp/claude-501/-Users-hropl-pr-mypr-PB3/bf5b1530-d3ab-4d27-baf8-fc027fd27f1b/scratchpad/nsol'
tr=json.load(open(f'/Users/hropl/pr/mypr/PB3-wt/nova-sol/docs/qa/playthrough/{src}/trace.json'))
wps=[]
for t in range(t0+step,t1,step):
    p=tr[t]['players'][0];wps.append([p['x'],p['y'],48,48])
p=tr[t1-1]['players'][0];wps.append([p['x'],p['y'],24,32])
c={"entry":entry,"goal_entry":goal,"waypoints":wps,"weights":{"net":0.3},"extra_pads":[136,137,138,8,9,10],"extra_rate":0.2,"min_gain":5,"slack":0,"length":240,"rollouts":4,"workers":2,"commit":0.5,"max_ticks":20000,"boss_weight":60,"boss_min_life":12,"y_weight":1.0,"life_weight":150,"energy_weight":40,"seed":1234,"name":name,"out":f"{S}/{name}_out.json","resume":False}
json.dump(c,open(f'{S}/{name}.json','w'));print(len(wps))
