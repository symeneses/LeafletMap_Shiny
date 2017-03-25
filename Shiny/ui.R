#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)


# Define UI for application that shows a map with the gross debt of countries in Europe
navbarPage("Gross debt", id="nav",
           
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        leafletOutput("map", width = "100%", height = "600"),
                        
                        # Parameters to create the map
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE,  top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 330, height = "auto",
                                      
                                      h2("Parameters"),
                                      
                                      sliderInput("year", "Year", min = 2005, max = 2015, value = 2015, step = 1),
                                      selectInput("uni", "Units", c("Porcentage of gross domestic product (GDP)" = "PC_GDP","Million Euro" = "MIO_EUR"), selected = "PC_GDP")
                        ),
                        
                        tags$div(id="cite",
                                 'Data source: ', tags$em('Eurostat General government gross debt - annual data')
                        )
                    )
           ),
           
           tabPanel("Data explorer",
                    hr(),
                    DT::dataTableOutput("gross_debt_year")
           ),
           
           conditionalPanel("false", icon("crosshair"))
)
