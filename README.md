# Co-Ni-MIPAR-Image-Segmentation
 Recipies and Matlab code for segmenting SEM micrographs for secondary and tertiary gamma prime in Superalloys

Two methods of Image Segmentation presented: 
 1. Interactive Matlab environment for simple Image segmentation based on a threshold grey intensity value and fitting multiple gaussians to output data. The main script for this is m_sizedist
 2. Using commercial software MIPAR with a custom recipe (RR-CoNi-Try2.rcp advised) and associated MATLAB script for proscessing .csv exported data - m_plot_MIPAR_output

Also contained in the file are useful functions for dealing with image segmentation:
 * Extract scale data and units from SEM tiff images automatically - f_getSEMScaleData
 * Interactivley fit an arbitary number of gaussians to histogram data - f_FitmultGauss

For method 1:
 * Choose the tiff file of your image using the UI selection
 * Select the appropriate threshold value for your image by moving the slider
 * Wait for the image to be segmented - holes are automatically filled
 * Histogram of area fraction is plotted
 * On this Histogram, you will be prompted to give estimates of the mean and standard deviation for the multi-modal gaussian fit. You can give these by interactivley first drawing a point on the mean estimate and a line representing the std estimate as shown below:

![STD estimate](./multiple_gauss_example.png) 

Method 2:
 * You will need to download MIPAR (https://www.mipar.us)
 * Refer to their documentation for how to use the custom recipe
 * The suggested Recipe will need tweaking for different microstructures and imaging conditions but the basic proscess should remain the same.
 * The recommended recipe RR-CoNi-Try2.rcp does the following:

SECONDARY
 1. Crop Image – remove scale bar etc.
 2. Gaussian Blur: 0.5 
 3. Adaptive Threshold – find all ppts
 4. Reject Features: Area < 5 px^2 – remove noise
 5. Separate Features: 3.00 High 1 None
 6. Fill All Holes 
 7. Uniform Erosion: 10.0 nm  - separates out small features
 8. Reject Features: Area 300 nm^2 – reject tertiaries
 9. Uniform Dilation: 10.0 nm – go back to original size
 10. Smooth Features:
 11. Separate Features: - final separation of ppts
 12. Fill All Holes – fills ppts in if they have not been already
 13. Remove Edge Features – edge features will bias histogram
![STD estimate](./MIPAR_Secondary_example.png) 

TERTIARY
 1. Invert  Secondary   -  find the ‘matrix’
 2. Basic Threshold: - find all tertiaries and secondaries
 3. Merge Lighter Pixels  -  only accepts threshold points outside of secondary area
 4. Remove Edge Features  - edge features bias the histogram
 5. Reject Features: Area  > 50 nm^2  - get rid of noise
 6. Separate Features – separate tertiaries that are close but not touching
 7. Reject Features: Area 2000 nm^2 – reject anything that is too big, these are likely secondaries that were not caught on the first pass
![STD estimate](./MIPAR_Tertiary_example.png) 

