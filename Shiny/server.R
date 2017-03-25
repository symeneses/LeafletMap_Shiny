#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(dplyr)
library(eurostat)

#Load the data
gross_debt <- get_eurostat("teina225", time_format = "num")
vars <- label_eurostat_vars(gross_debt)

# Define server logic required to create the map
shinyServer(function(input, output) {
  
  #Create the map
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>% 
      setView(10,55,zoom = 4) 
  })
  
  observe({
    year <- input$year
    uni <- input$uni
    gross_debt_year <- gross_debt %>%
      filter(time == year & unit == uni)
    gross_debt_year_lbl <- label_eurostat(gross_debt_year, code = "geo")
    # merge the filter data with wgeospatial data 
    gross_debt_geo <- merge_eurostat_geodata(gross_debt_year_lbl, geocolumn="geo_code", resolution=60,
                                             output_class="spdf", all_regions=FALSE)
    #define a pallete acording to the data
    pal <- colorBin("Spectral", gross_debt_geo$values, pretty = TRUE)
    country_popup <- paste0(as.character(gross_debt_geo[["geo"]])," ", gross_debt_geo[["values"]])

    #Send the data to the map object
    leafletProxy('map',data = gross_debt_geo) %>% 
      clearShapes() %>%
      clearPopups() %>%
      addPolygons(fillColor = ~pal(values), stroke = FALSE,
                  popup = country_popup)%>%
      addLegend("bottomleft", pal = pal, values = ~values,
                title = paste0(gross_debt_year_lbl[1,"unit"]," ",year),layerId="colorLegend")
    
    #Creat table with the data filtered
    output$gross_debt_year <- DT::renderDataTable({
      gross_debt_table <- gross_debt_year_lbl %>%
                          select(unit,geo,time,values)
      DT::datatable(gross_debt_table, colnames = c(vars[1],vars[4],"Year","Values"),escape = FALSE)
    })
  })
})
