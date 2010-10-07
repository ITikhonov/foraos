
PUSHLR=0xe92d4000
POPPC=0xe8bd8000
DUP=0xe5ab0004

def load():
	forth=[]
	numbers=[]
	r=open('code.dict').read()[0x2200:]
	from struct import unpack
	for o in range(0,4096,32):
		forth.append(unpack('HHHH HHHH HHHH HHHH',r[o:o+32]))

	r=open('code.dict').read()
	for o in range(0,512,4):
		numbers.append(unpack('I',r[o:o+4])[0])
	return forth,numbers

def names():
	names=[]
	r=open('code.dict').read()[0x3200:]
	for i in range(0,1024,8):
		names.append(r[i:i+8])
	return names

def inline(y):
	if y&0x8000: return numbers[y^0x8000]

	return inline(forth[y][1])

backref=a=[(x,[]) for x in range(0,128)]

addr=[]
code=[]

CONDAL=0xe0000000

def condify(cond,s):
	if cond is None: return s
	return [cond|(x&0x0fffffff) for x in s]

troubles=[]


def c1(cond,y):
	if y==0: return (None,[])
	r=[]
	if y&0x8000:
		r=condify(cond,[DUP,0xe59a0000|((y^0x8000)*4)])
		cond=None
	elif forth[y][0]==1:
		r=condify(cond,[inline(z) for z in forth[y][1:] if z!=0])
		cond=None
	elif forth[y][0]==2:
		cond=inline(forth[y][1])
	elif forth[y][0]==3:
		r=condify(cond,[DUP,0xe28a0f00|(forth[y][1]^0x8000)])
		cond=None
	else:
		backref[y][1].append(len(code))
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
	addr.append(len(code))
	code.append(PUSHLR)
	if x[0]==1:
		code.extend([inline(z) for z in x[1:] if z!=0])
	else:
		cond=None
		c=[]
		i=0
		while i<len(x):
			y=x[i]
			if y==12:
				F1=len(code)
				code.extend(condify(cond,[0xea000000]))
				(_cond,B)=c1(None,x[i+2])
				code.extend(B)
				F2=len(code)
				code.extend([0xea000000])
				(_cond,A)=c1(None,x[i+1])
				code.extend(A)

				code[F1]|=len(B)
				code[F2]|=len(A)-1

				cond=None
				i+=3
				continue

			(cond,r)=c1(cond,y)
			code.extend(r)
			i+=1

	code.append(POPPC)


names=names()
forth,numbers=load()

for n,x in zip(names,forth):
	c(x,n)

for i,x in backref:
	for y in x:
		d=(addr[i]-y)-2
		code[y]|=d&0xffffff

#for (i,x) in zip(range(len(numbers)),numbers): print hex(i),hex(x)

for n,f,x in zip(names,forth,addr):
	if n=='        ': continue
	print hex(names.index(n))[2:],n,' '.join([hex(z)[2:] for z in f]),hex(x*4)


from struct import pack
open('compiled.bin','w').write(''.join([pack('I',x) for x in code]))
open('addr.bin','w').write(''.join([pack('I',x) for x in addr]))

if troubles:
	print
	print '!!!!'
	print '!!!! MORE THEN ONE COND, EXPECT TROUBLES in',' '.join(troubles)
	print '!!!!'
	print
