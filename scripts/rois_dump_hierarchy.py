"""Walk the classified GRAIL hierarchy held by ROIS (Grail.subs from TopCategory) and write
child<TAB>parent lines. Usage: python3 rois_dump_hierarchy.py OpenGALEN8_FULL out.tsv"""
import sys, time, re
from rois_client import Rois, nodes
name, out = sys.argv[1], sys.argv[2]
module = sys.argv[3] if len(sys.argv) > 3 else 'Grail'  # 'System' = unfiltered
r = Rois(client='py-dump')
sem = r.q('openModel', f'<Text>{name}.sem</Text>', 'System'); semid = re.search(r'Model id="([^"]+)"', sem).group(1)
gra = r.q('openSub', f'<Model id="{semid}"></Model><Text>{name}.gra</Text>', 'System'); mid = re.search(r'Model id="([^"]+)"', gra).group(1)
top = nodes(r.q('findNode', f'<Model id="{mid}"></Model><Node>NODE</Node><Text>TopCategory</Text><Text>INTERNAL</Text><Text>5</Text>'))[0]
seen = {top[0]: top[2]}; todo = [top[0]]; edges = []; t = time.time()
while todo:
    nid = todo.pop()
    for cid, flags, cname in nodes(r.q('subs', f'<Model id="{mid}"></Model><Node id="{nid}"></Node>', module)):
        edges.append((cname, seen[nid]))
        if cid not in seen:
            seen[cid] = cname; todo.append(cid)
    if len(edges) % 20000 == 0: print(len(seen), len(edges), round(time.time()-t), file=sys.stderr)
with open(out, 'w') as f:
    for c, p in edges: f.write(f'{c}\t{p}\n')
print('nodes', len(seen), 'edges', len(edges), 'secs', round(time.time()-t), file=sys.stderr)
