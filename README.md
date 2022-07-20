# BMLD

In the proposed algorithm, the detection of AMLD does not assume that the mixed layer has a density difference (∆ρ) close to zero (e.g. threshold methods), and it identifies MLDs regardless any a priori threshold. It also picks up the shallowest and deepest limits of the pycnocline by excluding middle breaks of the pycnocline, allowing the identification for unconventional density vertical distribution. 
The AMLD represents the last depths up to which ∆ρ is consistently small from the surface to the pycnocline, while the BMLD is the first depth after the pycnocline a from which ∆ρ is consistently small up to the seabed (Fig. 1).

Figure 1
<img src="Plots/AMLD_BMLD.png" width="400" height="500" />

The method is developped to cope with density profiles having heterogenous shapes in the upper mixed layer, with nested sub-structures such as small re-stratification at the surface, or when the pycnocline can include a small mixed layer (Fig. 2a, e, f) or presents different density gradients (stratified layers) within it (Fig. 2b and c). 

Figure 2
<img src="Plots/figA01.png" width="700" height="700" />

AMLD and BMLD have been identified developing an algorithm based on [Chu and Fan (2011)](https://doi.org/10.1007/s10872-011-0019-2) framework to produce a method able to cope with various density profiles exhibiting a pycnocline (Fig. 2). 

This page contains the code to extract BMLD from in situ profiles, an example and a brief description of the method

The function is attached to the paper published in XXXX

Add files:
Supplementary material of the paper
Function
Code in R to extract the AMLD and BMLD, and plot them
Dataset example

Write the method 
Descritption
and add some figures of the correct identification and errors. Refer to paper!!!!

