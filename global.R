###################
# global.R
# 
# Anything you want shared between your ui and server, define here.
###################
suppressPackageStartupMessages({
    ## App specific
    library(shiny)
    library(shinyjs)
    library(shinythemes)
    library(bs4Dash)
    library(shinyWidgets)
    library(fontawesome)
    library(DT)
  
    ## Plotting and Color
    library(colourpicker)
    library(pals)
    
    ## Project specific
    library(tidyverse)
    library(BayesSpace)
    library(pcds)
    library(ggridges)
  
})

options(shiny.maxRequestSize = 200*1024^2)

sel_choices = expand.grid(LETTERS, letters)
sel_choices = paste(sel_choices[, 1],
                    sel_choices[, 2], sep = "-")