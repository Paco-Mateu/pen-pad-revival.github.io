"""Classify a GRAIL composite with ROIS (Grail.which / whichG), e.g.
  python3 rois_which.py OpenGALEN8_FULL Inflammation hasLocation Pericardium
Prints the most specific existing concept (which) and the canonical composite (whichG)."""
import sys, re
from rois_client import Rois, nodes
name, base, attr, value = sys.argv[1:5]
r = Rois(client='py-which')
sem = r.q('openModel', f'<Text>{name}.sem</Text>', 'System'); semid = re.search(r'Model id="([^"]+)"', sem).group(1)
gra = r.q('openSub', f'<Model id="{semid}"></Model><Text>{name}.gra</Text>', 'System'); mid = re.search(r'Model id="([^"]+)"', gra).group(1)
body = (f'<Model id="{mid}"></Model><Node>{base}</Node><Node sub="linkclass">{attr}</Node>'
        f'<Node sub="qualifier">defining</Node><Node>{value}</Node>')
print('which :', r.q('which', body, 'Grail'))
print('whichG:', r.q('whichG', body, 'Grail'))
g = nodes(r.q('whichG', body, 'Grail'))
if g:
    print('supers:', [n for _, _, n in nodes(r.q('supers', f'<Model id="{mid}"></Model><Node id="{g[0][0]}"></Node>', 'Grail'))])
