
PUSHLR=0xe92d4000
POPPC=0xe8bd8000
DUP=0xe5ab0004

def load():
	forth=[]
	numbers=[]
	r=open('code.bin').read()
	from struct import unpack
	for o in range(0,4096,32):
		forth.append(unpack('HHHH HHHH HHHH HHHH',r[o:o+32]))

	r=open('numbers.bin').read()
	for o in range(0,512,4):
		numbers.append(unpack('I',r[o:o+4])[0])
	return forth,numbers

def names():
	names=[]
	r=open('names.bin').read()
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
	if not cond: return s
	return [cond|(x&0x0fffffff) for x in s]

def c(x):
	addr.append(len(code))
	code.append(PUSHLR)
	if x[0]==1:
		code.extend([inline(z) for z in x[1:] if z!=0])
	else:
		cond=None
		c=[]
		for y in x:
			if y==0: continue

			if y&0x8000:
				code.extend(condify(cond,[DUP,0xe59a0000|((y^0x8000)*4)]))
				cond=None
			elif forth[y][0]==1:
				code.extend(condify(cond,[inline(z) for z in forth[y][1:] if z!=0]))
				cond=None
			elif forth[y][0]==2:
				cond=inline(forth[y][1])
			else:
				backref[y][1].append(len(code))
				code.extend(condify(cond,[0xeb000000]))
				cond=None
	code.append(POPPC)


names=names()
forth,numbers=load()

for x in forth:
	c(x)

for i,x in backref:
	for y in x:
		d=(addr[i]-y)-2
		code[y]|=d&0xffffff

for x in code: print hex(x),

for n,f,x in zip(names,forth,addr):
	if n=='        ': continue
	print names.index(n),n,f,hex(x*4)


from struct import pack
open('compiled.bin','w').write(''.join([pack('I',x) for x in code]))
open('addr.bin','w').write(''.join([pack('I',x) for x in addr]))


