import cv2 as cv
import numpy as np
from matplotlib import pyplot as plt
img_rgb = cv.imread('img/ring_edge.jpg')
img_gray = cv.cvtColor(img_rgb, cv.COLOR_BGR2GRAY)
template = cv.imread('./img/ring_edge_template.jpg', 0)
blured = cv.GaussianBlur(img_gray,(25,25),0)

# template = cv.imread('img/testSmall.jpeg',0)
cv.imshow('image', blured)
cv.waitKey(0)
cv.destroyAllWindows()

w, h = template.shape[::-1]
res = cv.matchTemplate(img_gray,template,cv.TM_CCOEFF_NORMED)
threshold = 0.268

temp_w = -10
temp_h = -10
count = 0
loc = np.where( res >= threshold)
print(loc)
for pt in zip(*loc[::-1]):
    if abs(temp_w - pt[0]) > 4 or abs(temp_h - pt[1]) > 4:
        cv.rectangle(img_rgb, pt, (pt[0] + w, pt[1] + h), (0,0,255), 2)
        count = count+1
    temp_w = pt[0]
    temp_h = pt[1]
cv.imwrite('res.png',img_rgb)
print("count", count)