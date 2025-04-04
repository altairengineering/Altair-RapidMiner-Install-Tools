import random
import uuid
outfile = 'data.csv'
outsize = 1024 * 1024 * 1024 * 2 # 2GB
with open(outfile, 'a') as csvfile:
    size = 0
    while size < outsize:
        txt = '%s,%.6f,%.6f,%i\n' % (uuid.uuid4(), random.random()*50, random.random()*50, random.randrange(1000))
        size += len(txt)
        csvfile.write(txt)
