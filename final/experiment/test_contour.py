import cv2
import numpy as np;

img = cv2.imread('img/rings.jpg') #read image
hsv_img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)  #convert to hsv

# Range for lower red
lower_red = np.array([0,5,0])
upper_red = np.array([60,255,255])
mask1 = cv2.inRange(hsv_img, lower_red, upper_red)
# Range for upper range
lower_red = np.array([170,30,0])
upper_red = np.array([100,255,255])
mask2 = cv2.inRange(hsv_img,lower_red,upper_red)
# mask for lower and upper red
mask = mask1 + mask2
# Get image in red pixel only
redImage = cv2.bitwise_and(img.copy(), img.copy(), mask=mask)

gray = cv2.cvtColor(redImage, cv2.COLOR_BGR2GRAY)
blured = cv2.GaussianBlur(gray,(5,5),0)


# Read image
# im = cv2.imread(blured, cv2.IMREAD_GRAYSCALE)

# Setup SimpleBlobDetector parameters.
params = cv2.SimpleBlobDetector_Params()

# Change thresholds
params.minThreshold = 1 #10
params.maxThreshold = 100 #200

# Filter by Area.
params.filterByArea = True # True
params.minArea = 100 #1500

# Filter by Circularity
params.filterByCircularity = True #True
params.minCircularity = 0.1 #0.1

# Filter by Convexity
params.filterByConvexity = True #True
params.minConvexity = 0.0 #0.87

# Filter by Inertia
params.filterByInertia = True #True
params.minInertiaRatio = 0.0 #0.01

# Create a detector with the parameters
ver = (cv2.__version__).split('.')
if int(ver[0]) < 3:
    detector = cv2.SimpleBlobDetector(params)
else:
    detector = cv2.SimpleBlobDetector_create(params)

# Detect blobs.
keypoints = detector.detect(blured)

# Draw detected blobs as red circles.
# cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS ensures
# the size of the circle corresponds to the size of blob
total_count = 0
for i in keypoints:
    total_count = total_count + 1


im_with_keypoints = cv2.drawKeypoints(blured, keypoints, np.array([]), (0, 0, 255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

# Show blobs
cv2.imshow("Keypoints", im_with_keypoints)
cv2.waitKey(0)

print(total_count)