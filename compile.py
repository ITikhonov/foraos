map=(	"""\0###############"""
	"""################"""
	"""#!##############"""
	"""0123456789:;<=>?"""
	"""@ABCDEFGHIJKLMNO"""
	"""PQRSTUVWXYZ[\\]^_"""
	""" abcdefghijklmno"""
	"""pqrstuvwxyz#####""")
	


words=[x.split() for x in open('code.fth').read().split('\n')]
words=[x for x in words if x!=[]]

print words

right='atom compile run save'.split()

# three tables:
# atoms -> name
# defs

atomsname=['']+right

defs={}

for x in words:
	defs[x[0]]=x[1:]
	for w in x:
		if w not in atomsname:
			atomsname.append(w)

print 'atoms:',len(atomsname)

def u16(x):
	return chr(x&0xff)+chr(x>>8)

def ai(x):
	return atomsname.index(x)

f=open('names.bin','w')
for x in atomsname:
	s=''.join([chr(map.index(y)) for y in x])+'\x20'*(8-len(x))
	assert len(s)==8
	f.write(s)
assert f.tell()<=1024
f.write('\x20'*(1024-f.tell()))
f.close()

f=open('code.bin','w')
for x in atomsname:
	d=[u16(ai(y)) for y in defs.get(x,[])]
	s=''.join(d)
	assert len(s)<=32
	s=s+'\0'*(32-len(s))
	print x,repr(s)
	f.write(s)
f.write('\0'*(4096-f.tell()))
f.close()

print 'names:',atomsname



