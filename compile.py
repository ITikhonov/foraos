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

from sys import argv

words=[x.split() for x in open(argv[1]).read().split('\n')]
words=[x for x in words if x!=[]]

predef=[]
while words[0][0]=='PREDEFINED':
	predef.extend([x[1:-1] for x in words.pop(0)[1:]])

print predef
print words


def names():
        names=[]
        r=open('code.dict').read()[0x3200:]
        for i in range(0,1024,8):
                names.append(r[i:i+8])
        return names

if not predef:
	corenames=names()

# three tables:
# atoms -> name
# defs

atoms=predef
atoms.extend([None]*(128-len(atoms)))

numbers=[0]
extern=[]

def atom(x):
	if '\\' in x:
		if x not in extern: extern.append(x)
		return 0x4000+extern.index(x)
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

from cStringIO import StringIO
f=StringIO()
for x in atoms:
	try:
		s=''.join([chr(map.index(y)) for y in x])+'\x20'*(8-len(x))
	except:
		print "'%s'"%(x,)
		raise
	assert len(s)==8,s
	f.write(s)
assert f.tell()<=1024
f.write('\x20'*(1024-f.tell()))
assert f.tell()==1024
names_bin=f.getvalue()
f.close()


linkage=[]
f=StringIO()
for x in atoms:
	d=defs.get(atom(x))
	if d:
		d2=[]
		for i in range(len(d)):
			y=d[i]
			if y&0x4000:
				d2.append('\xff\xff')
				linkage.append((extern[(y^0x4000)],f.tell()+i*2))
			else:
				d2.append(u16(y))
		d=d2
	else:
		if x and atom(x)>=0x18:
			print 'NO DEFINITION FOR "%x: %s"'%(atom(x),x)
			#assert False,x
		d=[]
	s=''.join(d)
	assert len(s)<=32,x
	s=s+'\0'*(32-len(s))
	print x,repr(s)
	f.write(s)
f.write('\0'*(4096-f.tell()))
assert f.tell()==4096
code_bin=f.getvalue()
f.close()

f=StringIO()
for x in numbers:
	f.write(u32(x))
f.write('\0'*(512-f.tell()))
assert f.tell()==512
numbers_bin=f.getvalue()
f.close()

font_bin=open('font.bin').read()

name=argv[1].rsplit('.',1)[0]
open(name+'.dict','w').write(numbers_bin+font_bin+code_bin+names_bin)

open(name+'.link','w').write(repr(linkage))

