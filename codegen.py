
PUSHLR=0xe92d4000
POPPC=0xe8bd8000
DUP=0xe5ab0004

def load(x):
	forth=[]
	numbers=[]
	r=open(x).read()[0x2200:]
	from struct import unpack
	for o in range(0,4096,32):
		forth.append(unpack('HHHH HHHH HHHH HHHH',r[o:o+32]))

	r=open(x).read()
	for o in range(0,512,4):
		numbers.append(unpack('I',r[o:o+4])[0])
	return forth,numbers

def loadnames(x):
	names=[]
	r=open(x).read()[0x3200:]
	for i in range(0,1024,8):
		names.append(r[i:i+8])
	return names

def inline(y):
	if y&0x8000: return _numbers[y^0x8000]
	return inline(_forth[y][1])

backref={}

addr=[]
code=[]

CONDAL=0xe0000000

def condify(cond,s):
	if cond is None: return s
	return [cond|(x&0x0fffffff) for x in s]

troubles=[]

def c1(cond,y,locals):
	if y==0: return (None,[])
	r=[]

	if y&0x8000:
		r=condify(cond,[DUP,0xe59f0000])
		locals.append((len(code),_numbers[y^0x8000]))
		cond=None
	elif _forth[y][0]==1:
		r=condify(cond,[inline(z) for z in _forth[y][1:] if z!=0])
		cond=None
	elif _forth[y][0]==2:
		cond=inline(_forth[y][1])
	else:
		if y not in backref: backref[y]=[]
		backref[y].append(len(code))
		r=condify(cond,[0xeb000000])
		cond=None
	return (cond,r)

"""
000000a8 <ifelse>:
  a8:	0a000002 	beq	b8 <.ifelse.A>
  ac:	00000001 	andeq	r0, r0, r1
  b0:	00000002 	andeq	r0, r0, r2
  b4:	ea000001 	b	c0 <.ifelse.exit>
000000b8 <.ifelse.A>:
  b8:	00000001 	andeq	r0, r0, r1
  bc:	00000002 	andeq	r0, r0, r2
000000c0 <.ifelse.exit>:
  c0:	00000001 	andeq	r0, r0, r1
  c4:	00000002 	andeq	r0, r0, r2
"""

def c(x,name):
	print name,' '.join([hex(y)[2:] for y in x])
	addr.append(len(code))
	code.append(PUSHLR)
	locals=[]
	if x[0]==1:
		code.extend([inline(z) for z in x[1:] if z!=0])
	elif x[0]==2:
		pass
	elif x[0]==3:
		code.extend([DUP,0xe28f0000,POPPC,_numbers[x[1]^0x8000]])
	else:
		cond=None
		c=[]
		i=0
		while i<len(x):
			y=x[i]
			if y==4:
				F1=len(code)
				code.extend(condify(cond,[0xea000000]))
				(_cond,B)=c1(None,x[i+2],locals)
				code.extend(B)
				F2=len(code)
				code.extend([0xea000000])
				(_cond,A)=c1(None,x[i+1],locals)
				code.extend(A)

				code[F1]|=len(B)
				code[F2]|=len(A)-1

				cond=None
				i+=3
				continue

			(cond,r)=c1(cond,y,locals)
			code.extend(r)
			i+=1

	code.append(POPPC)

	for (o,n) in locals:
		ns=code[o+1]
		assert 0x059f0000 == ns&0x0fffffff 

		code[o+1]|=(len(code)-o-1)*4-8
		code.append(n)
		print hex(n)

def norm0(x,n):
	if (x&0x7f00)!=0:
		return (x&0xff)+((x>>8)-1)*128
	return x+n*128

def norm1(f,n):
	return [norm0(x,n) for x in f]

def normalize(f,n):
	return [norm1(x,n) for x in f]

def all():
	global _names,_forth,_numbers
	from sys import argv
	names=[]
	forth=[]
	numbers=[]
	dicts=[]

	for x in argv[1:]:
		u=x.upper()
		dicts.append(u)
		names.append(loadnames(x))
		f,n=load(x)
		forth.append(normalize(f,len(forth)))
		numbers.append(n)


	_forth=[]
	for x in forth: _forth.extend(x)
	_numbers=[]
	for x in numbers: _numbers.extend(x)
	_names=[]
	for x in names: _names.extend(x)

	for x,n in zip(_forth,_names): c(x,n)

all()

for i,x in backref.items():
	for y in x:
		d=(addr[i]-y)-2
		if (code[y]&0x0f000000)==0x0b000000 and code[y+1]==POPPC:
			code[y]=(code[y]&0xf0000000)|0x0a000000
			d+=1
		code[y]|=d&0xffffff

for i in range(len(addr)):
	print hex(i),_names[i],hex(addr[i]*4)

from struct import pack
open('compiled.bin','w').write(''.join([pack('I',x) for x in code]))
open('addr.bin','w').write(''.join([pack('I',x) for x in addr]))

