"""Minimal client for the Kermanog ROIS terminology server (OpenGALEN toolset).
Protocol (observed with tcpdump between GCE.exe and ROIS.exe on TCP 3800):
each message is an XML <ROIS>...</ROIS> document terminated by four NUL bytes; one
persistent session: client hello -> project -> queries."""
import socket, re, sys
from xml.sax.saxutils import escape

class Rois:
    def __init__(self, host='127.0.0.1', port=3800, user='erik', project='Default', client='GCE', timeout=600):
        self.s = socket.create_connection((host, port)); self.s.settimeout(timeout); self.buf = b''
        print(self.raw(f'<ROIS><Client>{client}</Client><User>{user}</User><NameSpace>INTERNAL</NameSpace></ROIS>'), file=sys.stderr)
        print(self.raw(f'<ROIS><Project>{project}</Project></ROIS>'), file=sys.stderr)
    def raw(self, xml):
        self.s.sendall(xml.encode('latin-1') + b'\0\0\0\0')
        while True:
            m = re.search(rb'(</ROIS>|^OK|^ERROR[^\0]*)', self.buf)
            if m and (self.buf.find(b'</ROIS>') >= 0 or not self.buf.startswith(b'<')):
                end = self.buf.find(b'</ROIS>')
                end = end + 7 if end >= 0 else m.end()
                out, self.buf = self.buf[:end], self.buf[end:].lstrip(b'\0')
                return out.decode('latin-1')
            x = self.s.recv(1 << 20)
            if not x: raise EOFError(self.buf)
            self.buf += x
    def q(self, task, body='', module=None):
        mod = f' module="{module}"' if module else ''
        return self.raw(f'<ROIS><Query{mod} task="{task}">{body}</Query></ROIS>')

def nodes(reply):
    return re.findall(r'<Node id="([^"]+)"(?: flags="(\d+)")?>(.*?)</Node>', reply)
