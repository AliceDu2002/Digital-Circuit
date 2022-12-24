import cv2
import numpy as np
from PIL import Image
img = np.asarray(Image.open('test_Z.jpg'), dtype = np.uint8)
# img = cv2.imread("test_Y.jpg", 0) #since the image is grayscale, we need only one channel and the value '0' indicates just that
# print(img.shape)
# print(img[135, 253])
# for i in range (img.shape[0]): #traverses through height of the image
#     for j in range (img.shape[1]): #traverses through width of the image
#         print(img[i][j])


# data = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0,1,1,0,0,0,1,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
data = [0]
data_i = 0
category = [0]
merge = [0]

formimg = np.zeros((640,480), dtype = np.uint8)

# buffer = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]  # length 19
buffer = [0] * 482

width = 480
# data_i = 480
print(f"len {len(img)} {len(img[0])}")
for i in range(1, len(img)):
    for j in range(0, len(img[0])):
        
        if img[i][j] > 130:
            data[data_i] = 0
            formimg[i][j] = 0
        else:
            data[data_i] = 1
            formimg[i][j] = 255
# while data_i < 153:
        buffer.pop()
        if j == 0 or j == len(img[0])-1:
            buffer.insert(0, 0)
            # data_i += 1
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
                    # if buffer[width] != merge[buffer[0]] and merge[buffer[0]] != buffer[0]:
                    #     merge[buffer[width]] = merge[buffer[0]]
                    # elif buffer[0] > buffer[width]:
                    #     merge[buffer[0]] = buffer[width]
                    # else:
                    #     merge[buffer[width]] = buffer[0]
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
            # data_i += 1
        else:
            buffer.insert(0,0)
            # data_i += 1
       
count = 0 
for i in range(len(category)-1, 0, -1):
    if merge[i] == i:
        print(category[i])
        count += 1
    else:
        category[merge[i]] += category[i]
        category[i] = 0
print("count:", count)
        
# print(category)
# print(merge)
    
max = 0    
for i in range(0, len(category)):
    if category[i]>max:
        max = category[i]

finalcount = 0
for i in range(0, len(category)):
    if category[i] > 0.1*max:
        finalcount += 1
print("Final Count:", finalcount)

image = Image.fromarray(formimg, "L")
image.save("test_ZZ.jpg")