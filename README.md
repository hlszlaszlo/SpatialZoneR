# SpatialZoneR

The **SpatialZoneR** R Shiny app provides an interactive graphical user interface (GUI) for analyzing subspot resolution spatial transcriptomics (10X Visium) data preprocessed with [BayesSpace](https://doi.org/10.1038/s41587-021-00935-2).

How to cite:
> Andreas Patsalos, Laszlo Halasz, Darby Oleksak, Xiaoyan Wei, Gergely Nagy, Petros Tzerpos, Thomas Conrad, David W. Hammers, H. Lee Sweeney and Laszlo Nagy. Spatiotemporal transcriptomic mapping of regenerative inflammation in skeletal muscle reveals a dynamic multilayered tissue architecture. JCI (2024) https://doi.org/10.1172/JCI173858

# Features
- Visualization of spatial gene expression (subspot resolution).
- Supervised labelling to define tissue zones.
- Extraction and visualization gene expression for tissue zones for downstream analysis.

# Installation

R dependencies
```
install.packages(c("shiny", "shinyjs", "shinythemes", "shinyWidgets", "bs4Dash", "DT", "fontawesome", "pals", "tidyverse", "colourpicker", "pcds", "ggridges"))
```

Bioconductor dependencies
```
# Install the Bioconductor package manager, if necessary
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("BayesSpace")
```

```
devtools::install_github("hlszlaszlo/SpatialZoneR")
shiny::runApp()
```

# Introduction
This app allows users to manually define regions of interest (ROIs; tissue zones) and extract/visualize gene expression for a list of genes for Visium spatial transcriptomics data analyzed by BayesSpace (subspot resolution).

<figure>
<img src="./images/SpatialZoneR.png" alt="SpatialZoneR" />
</figure>

# To do list
- Selection control: Make already selected subspots remain highlighted after clicking "Add selection".
- Selection control: Allow users to unselect a subspot without requiring a restart of the selection process.
- Enable analysis of regular Visium datasets at spot resolution.
- Gene module score: Add functionality to calculate and plot module score for a list of genes.
- K-means clustering: Incorporate k-means clustering for data analysis and visualization.
- Image overlay and transparency and plot rotation.
