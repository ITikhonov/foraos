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
numbers='0 1 2 3 4 5 6 7 8 9 A B C D E F'.split()

# three tables:
# atoms -> name
# defs

atomsname=['']+numbers+right

for x in words:
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
f.close()

f=open('code.bin','w')
for x in words:
	d=[u16(ai(y)) for y in x]
	s=''.join(d)
	s=s+'\0'*(32-len(s))
	print x[0],repr(s)
	f.write(s)
f.write(('\0'*32)*(32-len(words)))
f.close()

print 'names:',atomsname



