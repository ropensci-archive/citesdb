library(shiny)
library(tidyverse)
library(echarts4r)
library(RColorBrewer)

set.seed(101)

dat <- read_rds(here::here("vignettes/pangolin_dat.rds"))

ui <- fluidPage(

    sidebarLayout(
        sidebarPanel(width = 3,
                     sliderInput("year",
                                 "Year",
                                 min = min(dat$year, na.rm = TRUE),
                                 max = max(dat$year, na.rm = TRUE),
                                 value = 2017,
                                 sep = "",
                                 step = 1)

        ),
        mainPanel(
            tabsetPanel(
                tabPanel("Connectivity Map - echarts4r",
                         fluidRow(
                             column(12, echarts4rOutput("map"))
                         )
                )
            )
        )
    )
)

server <- function(input, output) {

    #https://ecomfe.github.io/echarts-examples/public/editor.html?c=geo-lines
    # echarts4r map
    output$map <- renderEcharts4r({

        mdat <- dat %>%
            filter(year == input$year
            ) %>%
            arrange(term) %>%
            group_by(term)

        title <- input$year
        subtitle <- paste("CITES Reporting Countries:", unique(mdat$n_reporting))

        mdat %>%
            e_charts(start_lon) %>%
            e_geo(roam = TRUE,
                  label = list(emphasis = list(show = FALSE)),
                  itemStyle = list(normal = list(areaColor = '#323c48', borderColor = '#404a59'),
                                   emphasis = list(areaColor = '#323c48', borderColor = '#404a59')
                  )
            ) %>%
            e_lines(start_lon, start_lat, end_lon, end_lat, silent = FALSE,
                    source_name = start, target_name = end,
                    effect = list(show=T, period=3, trailLength=0, symbolSize=3),
                    lineStyle = list(normal = list(curveness = -.20, width = 1))) %>%
            e_effect_scatter(start_lat, coord_system = "geo",
                             size = n_scale,
                             scale = NULL,
                             #bind = start, # signals to tooltip
                             silent = TRUE) %>%
            e_color(background = "black") %>%
            e_theme("chalk") %>%
            e_tooltip(trigger = "item",
                      formatter = htmlwidgets::JS("
             function(params){
             return('Origin: ' + params.data.source_name +'<br />' +
                    'Destination: ' + params.data.target_name
                        )
             }")) %>%
            e_legend(textStyle = list(color = '#fff'), bottom = "5%") %>%
            e_title(title, subtitle, left = "50%", textAlign = "center")

    })
}

# Run the application
shinyApp(ui = ui, server = server)
