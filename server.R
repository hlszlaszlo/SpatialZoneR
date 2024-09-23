###################
# server.R
# 
# For all your server needs 
###################
server = function(input, output, session) {
  
  SpatialDataSCE = reactive({
    req(input$file)
    readRDS(input$file$datapath)
  })
  
  SpatialDataPoly = reactive({
    req(input$file)
    req(input$search)
    dat1 = readRDS(input$file$datapath)
    gg1 = featurePlot(dat1, feature = input$search)
    gg1$data %>% select(x.vertex, y.vertex, fill, spot)
  })
  
  output$featureselect = renderUI({
    req(input$file)
    dat1 = SpatialDataSCE()
    if (is.null(dat1))
      return(NULL)
    tagList(
      textInput(inputId = "ExpID", label = "Experiment name", value = "Visium"),
      selectizeInput(inputId = "search", label = "Search gene symbol", selected = "Spp1", choices = rownames(dat1), multiple = FALSE),
      selectizeInput(inputId = "colorpalette", label = "Choose color palette", choices = ls("package:pals")[!grepl("pal.", ls("package:pals"))], selected = "ocean.balance", multiple = FALSE),
      selectizeInput(inputId = "select_genes", label = "Extract zone expression for:", rownames(dat1), multiple = TRUE),
      actionButton("extractgenes", "Extract", icon = icon("bolt"), status = "warning", width = 300), br(), br(),
      numericInput(inputId = "ggplot_width", label = "Plot width", value = 12),
      numericInput(inputId = "ggplot_height", label = "Plot height", value = 10)
    )
  })
  
  output$sliderUI = renderUI({
    dat1 = SpatialDataPoly()
    if (is.null(dat1))
      return(NULL)
    x_min = round(min(dat1$x.vertex)) - 1
    x_max = round(max(dat1$x.vertex)) + 1
    y_min = round(min(dat1$y.vertex)) - 1
    y_max = round(max(dat1$y.vertex)) + 1
    tagList(
      sliderInput("slider_coord_x", "X", min = x_min, max = x_max, value = c(x_min, x_max)),
      sliderInput("slider_coord_y", "Y", min = y_min, max = y_max, value = c(y_min, y_max))
    )
  }) 
  
  observeEvent(input$update_btn, {
    updateSliderInput(session, "slider_coord_x", value = input$slider_coord_x)
    updateSliderInput(session, "slider_coord_y", value = input$slider_coord_y)
  })
  
  spatialfeature_static_plot = reactive({
    dat1 = SpatialDataPoly()
    input_palette = do.call(input$colorpalette, args = list(n = 100))
    ggplot(data = dat1, 
           aes(x = x.vertex, y = y.vertex, group = spot, fill = fill)) +
      geom_polygon() +
      coord_equal() + 
      scale_fill_gradientn(colours = input_palette) +
      scale_x_continuous("X-axis") +
      scale_y_continuous("Y-axis") +
      coord_cartesian(xlim = input$slider_coord_x, ylim = input$slider_coord_y) + 
      theme_bw() 
  })
  
  output$spatialfeature_static_plot = renderPlot({
    req(input$file)
    spatialfeature_static_plot()
  })
  
  output$downloadSpatialFeaturePlot = downloadHandler(
    filename = function() {paste("SpatialFeaturePlot_", input$search, '.svg', sep='')},
    content = function(file) {
      ggsave(file, plot = spatialfeature_static_plot(), device = "svg", width = input$ggplot_width, height = input$ggplot_height)
    }
  )
  
  selectedTriangle = function(pt) {
    dat1 = SpatialDataPoly()
    x = dat1$x.vertex
    y = dat1$y.vertex
    indices = seq(1, nrow(dat1), by = 3)
    Triangles = lapply(indices, function(i) {
      A = c(x[i], y[i])
      B = c(x[i + 1], y[i + 1])
      C = c(x[i + 2], y[i + 2])
      rbind(A, B, C)
    })
    inTriangle = 3 * (which(sapply(Triangles, function(tr) {pcds::in.triangle(pt, tr)$in.tri})) - 1) + 1
    selected = rep(FALSE, nrow(dat1))
    selected[c(inTriangle, inTriangle + 1, inTriangle + 2)] <- TRUE
    selected
  }
  
  # Reactive to track selected polygons, initialized based on input RDS data
  selectedPoly = reactiveVal(NULL)
  
  # Observe to initialize selectedPoly when SpatialDataPoly is available
  observe({
    req(SpatialDataPoly())  # Ensure SpatialDataPoly is available
    selectedPoly(rep(FALSE, nrow(SpatialDataPoly())))  # Initialize based on its size
  })
  
  output$clickcoord <- renderPrint({
    print(input$plot_clickPoly)
  })
  
  observeEvent(input$plot_clickPoly, {
    clicked = input$plot_clickPoly
    pt = c(clicked$x, clicked$y)
    selected = selectedTriangle(pt)
    selectedPoly(selected | selectedPoly())
  })
  
  observeEvent(input$plot_resetPoly, {
    poly = SpatialDataPoly()
    selectedPoly(rep(FALSE, nrow(poly)))
  })
  
  output$plot_DTPoly = DT::renderDataTable({
    poly = SpatialDataPoly()
    poly$sel = selectedPoly()
    poly[, "color"] = input$radiocolor
    poly = filter(poly, sel == TRUE)
    poly
  })
  
  final_DT = reactiveValues()
  final_DT$df = data.frame()
  
  FinalData = eventReactive(input$addToDT, {
    poly = SpatialDataPoly()
    poly$sel = selectedPoly()
    poly = filter(poly, sel == TRUE)
    poly[, "geneID"] = input$search
    poly[, "color"] = input$radiocolor
    poly[, "ExpID"] = input$ExpID
    final_DT$df = bind_rows(final_DT$df, poly)
  })
  
  output$final_DT = renderDataTable({
    FinalData()
  }, editable = TRUE, escape = FALSE, server = FALSE, extensions = c("Buttons"), options = list(dom = 'Bfrtip', buttons = c('copy', 'csv', 'excel', 'pdf')))
  
  observeEvent(input$addToDT, {
    poly = SpatialDataPoly()
    selectedPoly(rep(FALSE, nrow(poly)))
  })
  
  output$SpatialPolyPlot = renderPlot({
    req(input$file)
    req(input$search)
    
    input_palette = do.call(input$colorpalette, args = list(n = 100))
    
    poly = SpatialDataPoly()
    poly$sel = selectedPoly()
    poly[, "groupped_col"] = "#ffffff00"
    
    poly = poly %>% mutate(groupped_col = case_when(poly$sel == TRUE ~ input$radiocolor))
    
    ggplot(poly, 
           aes(x = x.vertex, 
               y = y.vertex, 
               group = spot, 
               fill = fill,
               color = sel)) + 
      geom_polygon() + 
      scale_color_manual(values = c("#ffffff00", input$radiocolor)) + 
      theme_bw() + 
      scale_fill_gradientn(colours = input_palette) +
      coord_cartesian(xlim = input$slider_coord_x, ylim = input$slider_coord_y)
  })
  
  observeEvent(input$plotSelectedButton, {
    output$plotSelectedClass = renderPlot({
      sel_df = FinalData()
      ggplot(sel_df, 
             aes(x = x.vertex, 
                 y = y.vertex, 
                 group = spot, 
                 fill = color,
                 color = color)) + 
        geom_polygon(size = 1) + 
        scale_fill_manual(values = rev(unique(sel_df$color))) + 
        scale_color_manual(values = rev(unique(sel_df$color))) + 
        theme_bw() + 
        coord_cartesian(xlim = input$slider_coord_x, ylim = input$slider_coord_y)
    })
  })
  
  observeEvent(input$plotSelectedButton, {
    output$plotSelectedExpr = renderPlot({
      input_palette = do.call(input$colorpalette, args = list(n = 100))
      
      sel_df = FinalData()
      ggplot(sel_df, 
             aes(x = x.vertex, 
                 y = y.vertex, 
                 group = spot, 
                 fill = fill)) + 
        geom_polygon(size = 1) + 
        scale_fill_gradientn(colours = input_palette) +
        scale_color_manual(values = "#000000") + 
        theme_bw() + 
        coord_cartesian(xlim = input$slider_coord_x, ylim = input$slider_coord_y)
    })
  })
  
  observeEvent(input$plotSelectedButton, {
    output$plotSelectedDensity = renderPlot({
      sel_df = FinalData()
      sel_df = sel_df %>% 
        select(fill, spot, color) %>%
        distinct()
      ggplot(sel_df, aes(x = fill, y = color, fill = color, group = color, color = color)) + 
        geom_density_ridges(
          jittered_points = TRUE,
          position = position_points_jitter(width = 0.05, height = 0),
          point_shape = '|', point_size = 10, point_alpha = 1, alpha = 0.7
        ) +
        scale_color_manual(values = rev(unique(sel_df$color))) +
        scale_fill_manual(values = rev(unique(sel_df$color))) +
        theme_bw()
    })
  })
  
  observeEvent(input$extractgenes, {
    sel_df = FinalData()
    withProgress(message = 'Extracting gene expression', value = 0, {
      n = length(input$select_genes)
      for (i in 1:n) {
        dat1 = SpatialDataSCE()
        gg1 = featurePlot(dat1, feature = input$select_genes[i])
        gg1_data = gg1$data %>% 
          select(x.vertex, y.vertex, fill, spot)
        gg1_data = gg1_data %>% dplyr::filter(spot %in% sel_df$spot)
        gg1_data[, "sel"] = TRUE
        gg1_data[, "geneID"] = input$select_genes[i]
        gg1_data[, "ExpID"] = input$ExpID
        gg1_data = gg1_data %>% left_join(sel_df[, c("spot", "color")]) %>% distinct()
        sel_df = bind_rows(sel_df, gg1_data)
        
        incProgress(1/n, detail = paste0(input$select_genes[i], "..."))
        Sys.sleep(0.1)
      }
    })
    output$final_DT = renderDataTable({sel_df}, editable = TRUE, escape = FALSE, server = FALSE, extensions = c("Buttons"), options = list(dom = 'Bfrtip', buttons = c('copy', 'csv', 'excel', 'pdf')))
  })
}
