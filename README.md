# SpatialZoneR

The **SpatialZoneR** R Shiny app provides an interactive graphical user interface (GUI) for analyzing subspot resolution spatial transcriptomics data preprocessed with [BayesSpace](https://doi.org/10.1038/s41587-021-00935-2).

If you use the app please cite our paper:
> Andreas Patsalos, Laszlo Halasz, Xiaoyan Wei, Darby Oleksak, Cornelius Fischer, David W. Hammers, Lee Sweeney, Laszlo Nagy et al. Spatiotemporal macrophage subtype specification guides the formation of damage-clearing and regenerative inflammation tissue zones in physiological and chronic injury. Journal (2023) https://doi.org/asfasdfa

# Features
- Visualization of spatial gene expression.
- Supervised subspot labelling to define tissue zones.
- Extraction and visualization of normalized gene expression for tissue zones.

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
# Quick start
