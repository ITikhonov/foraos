map=(	"""\0###############"""
	"""################"""
	"""#!########*+,-##"""
	"""0123456789:;<=>?"""
	"""@ABCDEFGHIJKLMNO"""
	"""PQRSTUVWXYZ[\\]^_"""
	""" abcdefghijklmno"""
	"""pqrstuvwxyz#####""")
	

def number(s):
	if s=='': return None
	if len(s)==len([x for x in s if x in '0123456789abcdef']):
		return int(s,0x10)
	return None


words=[x.split() for x in open('code.fth').read().split('\n')]
words=[x for x in words if x!=[]]

print words

right='ATOM EXIT SAVE RUN PAGE0 PAGE1 PAGE2 PAGE3'.split()

# three tables:
# atoms -> name
# defs

atoms=['','NATIVE','COND','VAR']+right+['INIT','UP','DOWN']
atoms.extend([None]*(128-len(atoms)))

numbers=[0]

def atom(x):
	n=number(x)
	if n!=None:
		if n in numbers: return 0x8000+numbers.index(n)
		numbers.append(n)
		return 0x8000+numbers.index(n)

	if x not in atoms:
		atoms[atoms.index(None)]=x
	return atoms.index(x)

defs={}

for x in words:
	d=[atom(y) for y in x[1:]]
	defs[atom(x[0])]=d
	if d[0]==3:
		numbers.append(numbers[d[1]^0x8000])
		d[1]=0x8000|(len(numbers)-1)

def replace_None(x):
	if x is None: return ''
	return x

atoms=[replace_None(x) for x in atoms]

print atoms
print numbers
print defs

def u16(x):
	return chr(x&0xff)+chr(x>>8)

def u32(x):
	return chr(x&0xff)+chr((x>>8)&0xff)+chr((x>>16)&0xff)+chr((x>>24)&0xff)

f=open('names.bin','w')
for x in atoms:
	s=''.join([chr(map.index(y)) for y in x])+'\x20'*(8-len(x))
	assert len(s)==8,s
	f.write(s)
assert f.tell()<=1024
f.write('\x20'*(1024-f.tell()))
assert f.tell()==1024
f.close()

f=open('code.bin','w')
for x in atoms:
	d=defs.get(atom(x))
	if d:
		d=[u16(y) for y in d]
	else:
		if x and atom(x)>0xb:
			print 'NO DEFINITION FOR "%x: %s"'%(atom(x),x)
			assert False,x
		d=[]
	s=''.join(d)
	assert len(s)<=32,x
	s=s+'\0'*(32-len(s))
	print x,repr(s)
	f.write(s)
f.write('\0'*(4096-f.tell()))
assert f.tell()==4096
f.close()

f=open('numbers.bin','w')
for x in numbers:
	f.write(u32(x))
f.write('\0'*(512-f.tell()))
assert f.tell()==512
f.close()

