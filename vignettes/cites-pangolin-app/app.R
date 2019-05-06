library(shiny)
library(tidyverse)
library(echarts4r)
library(RColorBrewer)

dat <- read_rds(here::here("vignettes", "pangolin_dat.rds")) %>%
    arrange(year, n)

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

        dat2 = dat %>%
            filter(year == input$year
            ) %>%
            group_by(term)

        pal <-  scales::hue_pal()(n_distinct(dat2$term))

        my_scale <- function(x) scales::rescale(x, to = c(3, 10))

        # note cannot add bind to e_lines...can fork repo and try?
        dat2 %>%
            e_charts(start_lon) %>%
            e_geo(roam = TRUE, label = list(emphasis = list(show = FALSE)),
                  itemStyle = list(normal = list(areaColor = '#323c48', borderColor = '#404a59'),
                                   emphasis = list(areaColor = '#2a333d', borderColor = '#2a333d')
                                   )
            ) %>%
            e_color(background = "black") %>%
            e_theme("chalk") %>%
            e_lines(start_lon, start_lat, end_lon, end_lat, silent = TRUE,
                    effect = list(show=T, period=3, trailLength=0, symbolSize=3),
                    lineStyle = list(normal = list(curveness = -.20, width = 1))) %>%
            e_effect_scatter(start_lat, coord_system = "geo",
                             size = n,
                             scale = my_scale,
                             #symbol_size = 1,
                             bind = start,
                             silent = FALSE) %>%
            #e_tooltip(trigger = "item") %>%
            e_tooltip(trigger = "item",
                      formatter = htmlwidgets::JS("
             function(params){
             return('Origin: ' + params.name  )
             }")) %>%
            e_legend(textStyle = list(color = '#fff'))

    })
}

# Run the application
shinyApp(ui = ui, server = server)
