import numpy as np
import cv2 as cv
import math

# from google.colab.patches import cv_imshow
img = cv.imread('img/rings.jpg') #read image
hsv_img = cv.cvtColor(img, cv.COLOR_BGR2HSV)  #convert to hsv

# Range for lower red
lower_red = np.array([0,5,0])
upper_red = np.array([60,255,255])
mask1 = cv.inRange(hsv_img, lower_red, upper_red)
# Range for upper range
lower_red = np.array([170,30,0])
upper_red = np.array([100,255,255])
mask2 = cv.inRange(hsv_img,lower_red,upper_red)
# mask for lower and upper red
mask = mask1 + mask2
# Get image in red pixel only
redImage = cv.bitwise_and(img.copy(), img.copy(), mask=mask)

gray = cv.cvtColor(redImage, cv.COLOR_BGR2GRAY)
blured = cv.GaussianBlur(gray,(5,5),0)
ret, thresh = cv.threshold(mask,0,255,cv.THRESH_BINARY_INV+cv.THRESH_OTSU)

kernel = np.ones((5,5),np.uint8)
closing = cv.morphologyEx(thresh, cv.MORPH_CLOSE, kernel)

contours, heirarchy = cv.findContours(thresh, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

# for i in range(0, len(contours)):
#      contours_info = heirarchy[0][i]
#      if contours_info[2] == -1 and contours_info[3] == -1:
#           draw_cont_bult = cv.drawContours(blured, contours, i, (0, 255, 0), thickness = 3)
#           print(heirarchy[0][i])
#      if contours_info[2] == -1 and contours_info[3] == 1:
#           draw_inner_cont_bult = cv.drawContours(blured, contours, i, (255, 0, 0), thickness = 3)
#           print(heirarchy[0][i])

heirarchy = heirarchy[0]
max_area = cv.contourArea(contours[0])
total = 0 # total contour size
for con in contours:
     area = cv.contourArea(con) # get contour size
     total += area
     if area > max_area:
        max_area = area
diff = 0.1 # smallest contour have to bigger than (diff * max_area)
max_area = int(max_area * diff) # smallest contour have to bigger
average = int(total / (len(contours))) # average size for contour
radius_avg = int(math.sqrt(average / 3.14)) # average radius 

average = int(average * diff)

mask = np.zeros(thresh.shape[:2],dtype=np.uint8)
for component in zip(contours, heirarchy):
     currentContour = component[0]
     currentheirarchy = component[1]
     area = cv.contourArea(currentContour)
     if currentheirarchy[3] < 0 and area > average:
          cv.drawContours(mask, [currentContour], 0, (255), -1)
          
res1 = img.copy()
# count = 0 #result

# Store bounding rectangles and object id here:
objectData = []

# ObjectCounter:
objectCounter = 1

# Look for the outer bounding boxes (no children):
for _, c in enumerate(contours):
    # Get the contour's bounding rectangle:
    boundRect = cv.boundingRect(c)

    # Store in list:
    objectData.append((objectCounter, boundRect))

    # Get the dimensions of the bounding rect:
    rectX = boundRect[0]
    rectY = boundRect[1]
    rectWidth = boundRect[2]
    rectHeight = boundRect[3]

    # Draw bounding rect:
    color = (0, 0, 255)
    cv.rectangle(res1, (int(rectX), int(rectY)),
                  (int(rectX + rectWidth), int(rectY + rectHeight)), color, 2)

    # Draw object counter:
    font = cv.FONT_HERSHEY_SIMPLEX
    fontScale = 1
    fontThickness = 2
    color = (0, 255, 0)
    cv.putText(res1, str(objectCounter), (int(rectX), int(rectY)), 
                font, fontScale, color, fontThickness)

    # Increment object counter
    objectCounter += 1


cv.imshow('image', blured)
# cv.imshow('image', res1)
cv.waitKey(0)
cv.destroyAllWindows()

# img_rgb = cv.imread('img/ring_edge.jpg')
# template = cv.imread('./img/ring_edge_template.jpg', 0)

# w, h = template.shape[::-1]
# res = cv.matchTemplate(blured,template,cv.TM_CCOEFF_NORMED)
# threshold = 0.268

# temp_w = -10
# temp_h = -10
# count = 0
# loc = np.where( res >= threshold)
# print(loc)
# for pt in zip(*loc[::-1]):
#     if abs(temp_w - pt[0]) > 4 or abs(temp_h - pt[1]) > 4:
#         cv.rectangle(img_rgb, pt, (pt[0] + w, pt[1] + h), (0,0,255), 2)
#         count = count+1
#     temp_w = pt[0]
#     temp_h = pt[1]
# cv.imwrite('res.png',img_rgb)
# print("count", count)