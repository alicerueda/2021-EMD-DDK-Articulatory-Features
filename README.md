# 2021-EMD-DDK-Articulatory-Features

This repository contains the articulatory features extracted from decompposed voice Intrinsic Mode Fucntions (using Empirical Mode Decomposition).

The feature extract borrows the concept of "EMD as a Dyadic filterbank" from Patrick Flandrin. For function Gaussian, you can approximate the center freuqencies of subsequent IMF with a ratio of 2. For voice, when we look at vowel articulation, we look at the ratio of formants, such as F1/F2. We can apply this center frequency ratio from Flandrin's paper as articulatory measure. We can also use the IMF power ratio from his paper to see the power balancing between IMFs.

However, EMD has inherit mode mixing condition when the ratio of amplitude and component frequency does not satisfy the regions described in Rilling's paper "One or two frequencies? The empirical mode decomposition answers". To overcome the mode mixing condition, we assume that the same component (formant) can be spread across multiple IMFs and introduce the concept of Tolerance of Center frequency (fcdiff). The tolerance fcdiff describes the acceptable difference between the center frequency among adjacent IMFs. If fcdiff = 0.1 that means the IMFs pretty much has the same center frequency within 10%.

The feature extraction code is implemented in MATLAB. There are three files, the first file calls the other 2 to return the features described in the Elsevier CSL paper.


Files:
1. myEMDFeaturesPowerDyadic.m (returns all features described in the paper)
2. myThresholdingSumIMF.m 
3. myFindIMFCenterFreq.m


If you use the code or method, please cite: 
1. A. Rueda, J.C. Vasquez-Correa, J.R. Orozco-Arroyave, E. Noth, and S. Krishnan, "Empirical Mode Decomposition Articulation Feature Extraction on Parkinson's Diadochokinesia", Computer Speech and Language (in printing. Pre-print version available at https://www.sciencedirect.com/science/article/pii/S0885230821001170)
2. A. Rueda and S. Krishnan, "Clustering Parkinson's and Age-related Voice Impairment Signal Features for Unsupervised Learning," Advances in Data Science and Adaptive Analysis, 2018. https://doi.org/10.1142/S2424922X18400077


Questions and feedback: email: arueda@ryerson.ca
