import cv2
import numpy as np
from PIL import Image
import sys
 
input_img = "img/IMG_8201.jpeg"
grayscale_img = "test_Y.jpg"
binarize_img = "test_Z.jpg"
 
img = Image.open(input_img)
numpydata = np.asarray(img)

R = np.zeros((480, 640), dtype = np.uint8)
G = np.zeros((480, 640), dtype = np.uint8)
B = np.zeros((480, 640), dtype = np.uint8)
print(numpydata.shape)
for i in range(480):
    for j in range(640):
        R[i][j] = numpydata[i][j][0]
        G[i][j] = numpydata[i][j][1]
        B[i][j] = numpydata[i][j][2]
# RGB2YCrCb
Y = np.zeros((480, 640), dtype = np.uint8)
for i in range(480):
    for j in range(640):
       Y[i][j] = np.round(0.299*R[i][j] + 0.587*G[i][j] + 0.145*B[i][j])

img = Image.fromarray(Y, "L")
print(R.shape)
img.save(grayscale_img)

#-------------------blob---------------------

img = np.asarray(Image.open(grayscale_img), dtype = np.uint8)
#since the image is grayscale, we need only one channel and the value '0' indicates just that

data = [0]
data_i = 0
category = [0]
merge = [0]

formimg = np.zeros((480,640), dtype = np.uint8)
buffer = [0] * 642

width = 640

light_threshold = 130
size_threshold = 0.125

f = open("sequence.txt", "w")

for i in range(0, 640):
    f.write("0\n")

for i in range(1, len(img)):
    for j in range(0, len(img[0])):
        
        if img[i][j] > light_threshold:
            data[data_i] = 0
            formimg[i][j] = 0
            f.write("0\n")
        else:
            data[data_i] = 1
            formimg[i][j] = 1
            f.write("1\n")
        buffer.pop()
        if j == 0 or j == len(img[0])-1:
            buffer.insert(0, 0)
            continue
        if data[data_i]:        # if current is 1
            if buffer[0]:       # if its left is also 1 
                buffer.insert(0, buffer[0])
                category[buffer[0]] += 1
                if buffer[width] and buffer[width] != buffer[0]:    # if its top is also 1
                    if merge[buffer[0]] > merge[buffer[width]]:
                        merge[merge[buffer[0]]] = merge[buffer[width]]
                    elif merge[buffer[0]] < merge[buffer[width]]:
                        merge[merge[buffer[width]]] = merge[buffer[0]]
            elif buffer[width]:                                     # if left top is also 1
                category[buffer[width]] += 1
                buffer.insert(0, buffer[width])
            elif buffer[width-1]:                # if top is also 1
                category[buffer[width-1]] += 1
                buffer.insert(0, buffer[width-1])
            else:
                buffer.insert(0, len(category))
                category.append(1)
                merge.append(len(merge))
        else:
            buffer.insert(0,0)
print(merge)
count = 0 
for i in range(len(category)-1, 0, -1):
    if merge[i] == i:
        print(category[i])
        count += 1
    else:
        category[merge[i]] += category[i]
        category[i] = 0
print("count:", count)
    
max = 0    
for i in range(0, len(category)):
    if category[i]>max:
        max = category[i]

finalcount = 0
for i in range(0, len(category)):
    if category[i] > size_threshold*max:
        finalcount += 1
print("Final Count:", finalcount)
print("category", len(category))
print(merge)
image = Image.fromarray(formimg*255, "L")
image.save(binarize_img)