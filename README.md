# panoramic-image-stitching
## Requirements
 - MATLAB (tested on `R2021a`)
 - Image Processing Toolbox (for `imwarp`)
## Instruction
> This is a backup of my assignment 1 of **EE5731 Pattern Recognition**. This assignment consists of 7 parts, in which the part 7 has realised a panoramic image stitching of unordered images. 
### Folder list
    .
    ├─── part1.m            # convolution for different kernels
    ├─── part2.m            # finding key points using `sift`
    ├─── part3gui.fig       # GUI for homography
    ├─── part3gui.m         # GUI for homography
    ├─── part4.m            # stitching two images using user-chosen points
    ├─── part5.m            # stitching two images using `RANSAC`
    ├─── part6.m            # stitching multiple ordered images
    ├─── part7.m            # stitching multiple unordered images
    ---------------------------------------------------------------------
    ├─── siftWin32.exe      # **Windows** core application for `sift` from `siftDemoV4`
    ├─── sift               # **Unix** core application for `sift` from `siftDemoV4`
    ├─── getorder.m         # function for ordering images
    └─── README.md
    
## To-do list
 - [ ] bundle adjustment
 - [ ] gain compensation
 - [ ] multiband blending
