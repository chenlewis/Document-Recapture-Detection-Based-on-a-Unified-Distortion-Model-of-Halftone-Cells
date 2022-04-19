# Document-Recapture-Detection-Based-on-a-Unified-Distortion-Model-of-Halftone-Cells

The image datasets and result files are large and needed to be uploaded. The link will be available once the uploading is completed.

The project can be separated into three main parts:

1. Halftoned digital document generation

2. Halftone cell distortion parameter estimation

3. Hypothesis testing and result collection

## Halftoned Digital Document Generation

Interface function: halftone_gen.m

## Halftone Cell Distortion Parameter Estimation

Interface functions

1. mainRef.m: process the reference image (224x224 block)

2. mainDocGenuine.m: process the genuine document image (224x224 block)

3. mainDocRecapture.m: process the recaptured document image (224x224 block)

## Hypothesis Testing and Result Collection

1. mainCheckInterface.m: process the results of experiments under typical print and capture settings with comparison to benchmark methods.

2. mainCheckInterfaceConciseWithWild.m: process the results of experiments under typical print and capture settings without comparison to benchmark methods.

3. mainCheckInterfaceConciseAddition.m: process the results of experiments under other print and capture settings. 

4. mainCheckInterfaceConciseAdditionCamera.m: process the results of experiments on camera as capture device.
