map=(	"""\0###############"""
	"""################"""
	"""################"""
	"""0123456789:;<=>?"""
	"""@ABCDEFGHIJKLMNO"""
	"""PQRSTUVWXYZ[\\]^_"""
	""" abcdefghijklmno"""
	"""pqrstuvwxyz#####""")
	


words=[x.split() for x in open('code.fth').read().split('\n')]
words=[x for x in words if x!=[]]

print words

# three tables:
# atoms -> name
# defs

atomsname=['\0']

for x in words:
	for w in x:
		if w not in atomsname:
			atomsname.append(w)

def u16(x):
	return chr(x&0xff)+chr(x>>8)

def ai(x):
	return atomsname.index(x)

f=open('names.bin','w')
for x in atomsname:
	s=''.join([chr(map.index(y)) for y in x])+'\0'*(8-len(x))
	assert len(s)==8
	f.write(s)
f.write('\0')
f.close()

f=open('code.bin','w')
for x in words:
	d=[u16(ai(y)) for y in x]
	s=''.join(d)
	if (len(s)+2)%4==0: s=s+'\0\0\0\0'
	else: s=s+'\0\0'
	s=u16((len(s)+2))+s
	assert len(s)%4==0
	print x[0],repr(s)
	f.write(s)
f.write('\0\0\0\0')
f.close()

print 'names:',atomsname


