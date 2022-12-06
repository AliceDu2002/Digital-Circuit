# Import libraries
import cv2
import numpy as np
import matplotlib.pyplot as plt
image = cv2.imread('img/rings.jpg')
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
# plt.imshow(gray, cmap='gray')
plt.imsave("gray.jpg", gray, cmap='gray')

blur = cv2.GaussianBlur(gray, (11, 11), 0)
# plt.imshow(blur, cmap='gray')
plt.imsave("blur.jpg", blur, cmap='gray')

canny = cv2.Canny(blur, 30, 150, 3)
plt.imsave("canny.jpg", canny, cmap='gray')
# plt.imshow(canny, cmap='gray')

dilated = cv2.dilate(canny, (1, 1), iterations=0)
plt.imsave("dilate.jpg", dilated, cmap='gray')
# plt.imshow(dilated, cmap='gray')

(cnt, hierarchy) = cv2.findContours(
	dilated.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
cv2.drawContours(rgb, cnt, -1, (0, 255, 0), 2)

plt.imshow(rgb)
plt.imsave("rgb.jpg", rgb, cmap='gray')

print("items in the image : ", len(cnt))
