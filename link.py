from sys import argv

def loadnames(x):
        names=[]
        r=open(x).read()[0x3200:]
        for i in range(0,1024,8):
                names.append(r[i:i+8].strip())
        return names


names={}
for x in argv[1:]:
	names[x]=loadnames(x+'.dict')

for x in argv[1:]:
	link=eval(open(x+'.link').read())
	f=open(x+'.dict','r+')
	for ((d,n),o) in link:
		f.seek(0x2200+o)
		assert f.read(2)=='\xff\xff', (d,n,o)

		try: didx=argv.index(d.lower())
		except:
			print 'no %s dictionary (from %s)\n'%(d,x)
			exit(1)

		try: nidx=names[d.lower()].index(n)
		except:
			print names[d.lower()]
			print 'no %s in %s (from %s)\n'%(n,d,x)
			exit(1)

		f.seek(0x2200+o)
		f.write(chr(nidx)+chr(didx))
		print d,n,'=>',didx,nidx


