###################
# body.R
# 
# Create the body for the ui. 
# If you had multiple tabs, you could split those into their own
# components as well.
###################
body = dashboardBody(useShinyjs(),
                     chooseSliderSkin("Square"),
                     tags$head(tags$style(HTML('.content-wrapper {background-color: #fff;}'))),
                     fluidPage(fluidRow(
                               column(6,
                               fileInput("file", "Upload RDS File", accept = c(".rds")),
                               uiOutput("featureselect"),
                               downloadButton("downloadSpatialFeaturePlot")),
                               column(6,
                                      radioGroupButtons(
                                      inputId = "radiocolor",
                                      label = "Zone select",
                                      choiceValues = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33"),
                                      choiceNames = c("A", "B", "C", "D", "E", "F"),
                                      checkIcon = list(yes = icon("square-check"), no = icon("square"))),
                                      tags$script("$(\"input:radio[name='radiocolor'][value='#e41a1c']\").parent().css('background-color', '#e41a1c');"),
                                      tags$script("$(\"input:radio[name='radiocolor'][value='#377eb8']\").parent().css('background-color', '#377eb8');"),
                                      tags$script("$(\"input:radio[name='radiocolor'][value='#4daf4a']\").parent().css('background-color', '#4daf4a');"),
                                      tags$script("$(\"input:radio[name='radiocolor'][value='#984ea3']\").parent().css('background-color', '#984ea3');"),
                                      tags$script("$(\"input:radio[name='radiocolor'][value='#ff7f00']\").parent().css('background-color', '#ff7f00');"),
                                      tags$script("$(\"input:radio[name='radiocolor'][value='#ffff33']\").parent().css('background-color', '#ffff33');"),
                               uiOutput("sliderUI"),
                               actionButton("addToDT", "Add selection", icon = icon("plus"), width = 308), br(),
                               actionButton("plotSelectedButton", "Plot selection", icon = icon("chart-simple"), width = 308))), br(), hr(),
                     fluidRow(column(12,
                              plotOutput("SpatialPolyPlot", click = "plot_clickPoly", dblclick = "plot_resetPoly", height = 600), br(), hr(),
                              DT::dataTableOutput('plot_DTPoly'),
                              DT::dataTableOutput('final_DT'))),
                     fluidRow(column(4, plotOutput("plotSelectedClass")),
                              column(4, plotOutput("plotSelectedExpr")),
                              column(4, plotOutput("plotSelectedDensity")))),
     controlbar = dashboardControlbar()
)
