from PIL import Image
import matplotlib.pyplot as plt
import numpy as np

img = plt.imread('D:/ic_design/DIC_HW5/test_image_pattern/4.bmp')
#print(img)


weight = [[ 1 ,  2 ,  4],
      [ 8 ,  0 ,  16],
      [32 , 64 , 128]]

"""
[[(x-1,y-1),(x,y-1),(x+1,y-1)],
 [ (x-1,y) , (x,y) , (x+1,y) ],
 [(x-1,y+1),(x,y+1),(x+1,y+1)]

"""
#print(weight)
lbp = []

for x in range(128):
    for y in range(128):
        if x <= 0 or x >= 127 or y <= 0 or y >= 127:
            lbp.append(0)
        else:
            lbp_temp = 0
            theshold = img[x][y]
            if img[x-1][y-1] >= theshold:#左上
                lbp_temp += weight[0][0]
            if img[x][y-1] >= theshold:#中上
                lbp_temp += weight[1][0]
            if img[x+1][y-1] >= theshold:
                lbp_temp += weight[2][0]
            if img[x-1][y] >= theshold:
                lbp_temp += weight[0][1]
            if img[x+1][y] >= theshold:
                lbp_temp += weight[2][1]
            if img[x-1][y+1] >= theshold:
                lbp_temp += weight[0][2]
            if img[x][y+1] >= theshold:
                lbp_temp += weight[1][2]
            if img[x+1][y+1] >= theshold:
                lbp_temp += weight[2][2]
            lbp.append(lbp_temp)


img = np.reshape(img,(128*128))
pattern=open('D:/ic_design/DIC_HW5/pattern4.dat','w')
for i in range(len(img)):
           pattern.write('{0:x}'.format(img[i])+'\n')           
pattern.close()



golden=open('D:/ic_design/DIC_HW5/golden4.dat','w')
for i in range(len(lbp)):
           golden.write('{0:x}'.format(lbp[i])+'\n')         
golden.close()

        
       
