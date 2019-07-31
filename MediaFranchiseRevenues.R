library(shiny)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(plotly)
library(glue)
#extrafont::loadfonts(device="win")
library(ggplot2)
library(gridExtra)

media_franchises <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-02/media_franchises.csv")

franchises <- media_franchises %>% 
    group_by(franchise, original_media, year_created, creators, owners) %>% 
    summarize(categories = n(),
              total_revenue = sum(revenue),
              most_revenue = revenue_category[which.max(revenue)]) %>% 
    ungroup()



cbPalette <- c("#CC7EA8", "#CB6A0E", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


ui <- fluidPage(
    tags$head(tags$style(
        HTML('
        body, label, input, button, select { 
            font-family: "Calibri";
            background-color: black;
            color: white;
        }')
    )),
    tags$style(type = "text/css", "
      .irs-bar {width: 100%; height: 25px; background: #FFA71A; border-top: 1px solid #FFA71A; border-bottom: 1px solid #FFA71A;}
      .irs-bar-edge {background: black; border: 1px solid black; height: 25px; border-radius: 0px; width: 20px;}
      .irs-line {border: 1px solid black; height: 25px; border-radius: 0px;}
      .irs-grid-text {font-family: 'arial'; color: black; bottom: 17px; z-index: 1;}
      .irs-grid-pol {display: none;}
      .irs-max {font-family: 'arial'; color: black; background: #FFA71A}
      .irs-min {font-family: 'arial'; color: black; background: #FFA71A}
      .irs-single {color:black; background:#FFA71A;}
      .irs-slider {width: 30px; height: 30px; top: 22px;}
    "), 

    plotlyOutput("reddit"),
    hr(),
    plotlyOutput("plotlyversion"),
   
    sliderInput("nfranchise", label = "", value = 20, 
                min = 1, max = media_franchises %>% distinct(franchise) %>% nrow(),
                                    width = "1500px"),
    hr(),
    h4("About the viz"),
    uiOutput("summary"),
    hr(),
    h4("Exercise in customizing and polishing graphs in ggplot and plotly"),
    uiOutput("remarks"),
    hr(),
    h6("Sources: David Robinson's Screencast, R4DS TidyTuesday, and r/dataisbeautiful"),
    tags$a(tags$img(src="youtube.png", height = 40, width = 50),
           href="https://www.youtube.com/watch?v=1xsbTs9-a50"),
    tags$a(tags$img(src="r4ds.png", height = 60, width = 60),
           href="https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-07-02"),
    tags$a(tags$img(src="redditdata.png", height = 50, width = 50),
           href="https://www.reddit.com/r/dataisbeautiful/comments/c53540/highest_grossing_media_franchises_oc/")
    #tags$img(src = 'tidytuesday.jpg', height = 50, width = 100),
    #tags$img(src = 'redditdata.jpg', height = 50, width = 50)
)

server <- function(input, output) {
    
    output$summary<-renderUI({
        helpText("On r/dataisbeautiful, reddit user /u/takeasecond 
                 posted a visualization on the highest grossing media franchises
                 using data scraped from wikipedia. Following soon after,
                 the R4DS online community posted the data set for their
                 TidyTuesday, a weekly project aimed at making useful visualizations
                 using ggplot, tidyr, dplyr, and other tools within the tidyverse ecosystem.
                 David Robinson (Chief Data Scientist at DataCamp) posted his data exploration of the data set on a screencast
                 where he reproduced the graph of the highest grossing franchises.
                 I polished Robinson's ggplot graph to more closely resemble /u/takeasecond's graph
                 and produced a plot_ly version of the graph; these are embedded here into an web application to make
                 it interactive using plotly and shiny. The sources are hyperlinked below.")
        })
    output$remarks <- renderUI({
          helpText("The first plot uses plotly::ggplotly(); ggplot's functionality with stacked barplots and its interaction with ggplotly
                    is deprecated -- filtering the revenue categories using the legend does not push the remaining stacked bars
                    back onto its respective axis.

                    The second plot uses plotly::plot_ly(), which correctly pushes the bars back
                    onto the axis -- however, it is difficult to implement certain aesthetics, such as the total revenue text on each bar,
                    the spacing between the axis labels and the plot, and the (black) fill within the plots to separate revenue streams. 

                    More notably, the grammar of graphics to work between the two are different, 
                    so it was quite the learning experience customizing them to look similar
                    to each other. In terms of use cases with stacked barplots and plotly, ggplotly would be better suited for
                    static  reports and plot_ly would be better suited for interactive reports.")
    })
    
    top_franchises <- reactive({
        franchises %>%
            mutate(franchise = glue("{ franchise } ({ year_created })")) %>% 
            top_n(input$nfranchise, total_revenue)
    })
    
    
    output$reddit <- renderPlotly({
        reddit2 <- media_franchises %>% 
            mutate(franchise = glue("{ franchise } ({ year_created })")) %>% 
            semi_join(top_franchises(), by = "franchise") %>% 
            mutate(franchise = fct_reorder(franchise, revenue, sum)) %>% 
            mutate(revenue_category = fct_reorder(revenue_category, revenue, sum)) %>% 
            ggplot(aes(franchise, revenue)) +
            geom_col(aes(fill = revenue_category), color = "black") +
            geom_text(aes(y = total_revenue,
                          label = paste0(scales::dollar(total_revenue, accuracy = NULL), " B")),
                      data = top_franchises(), 
                      hjust = 0, 
                      color = "white",
                      size = 3.5, 
                      family= "Calibri Light") +
            scale_y_continuous(labels = scales::dollar) +
            coord_flip() +
            expand_limits(y = 100) +
            guides(fill = guide_legend(reverse = TRUE)) +
            labs(title = "Highest Grossing Media Franchises (ggplot)",
                 subtitle = "ggplot",
                 fill = "",
                 x = "",
                 y = "Revenue (Billions)") +
            theme(panel.grid.major.y = element_blank(),
                  legend.position = "top",
                  legend.background = element_rect(color = NA, fill = "grey15"),
                  legend.text = element_text(size = 9, color = "white",  family= "Calibri Light"),
                  legend.title = element_text(size = 8, face = "bold", hjust = 0.5, color = "white"),
                  plot.background = element_rect(color = "black", fill = "black"),  
                  plot.title = element_text(size = 15, color = "white", family= "Calibri Light", hjust = 0.5, face = "bold"),
                  axis.text.x = element_text(size = 12*0.8, color = "white", lineheight = 0.9, family= "Calibri Light"),  
                  axis.text.y = element_text(size = 12*0.8, color = "white", lineheight = 0.9, family= "Calibri Light"),
                  axis.title.x = element_text(size = 8, color = "white"),  
                  axis.title.y = element_text(size = 8, color = "white"),
                  panel.background = element_rect(fill = "black", color  =  NA),  
                  panel.border = element_rect(fill = NA, color = "black"),  
                  panel.grid.major = element_line(color = "grey35"),  
                  panel.grid.minor = element_line(color = "grey20"))
        reddit2 + scale_fill_manual(values=cbPalette) + guides(shape = guide_legend(override.aes = list(size = 5))) + theme(axis.text = element_text(size = 20))
    })
    
    
    stackedplotly <- reactive({
      redditplotly <- media_franchises %>% 
      mutate(franchise = glue("{ franchise } ({ year_created })")) %>% 
      semi_join(top_franchises(), by = "franchise") %>% 
      mutate(franchise = fct_reorder(franchise, revenue, sum)) %>% 
      mutate(revenue_category = fct_reorder(revenue_category, -revenue, sum))
    })
    
    output$plotlyversion <- renderPlotly({
      stackedplotly() %>% plot_ly(x = ~revenue,
                                  y = ~ franchise,
                                  color = ~revenue_category,
                                  colors = cbPalette) %>%
        #add_bars(x = ~revenue, y = ~franchise, color = ~revenue_category) %>%
        layout(barmode = "stack") %>% 
        layout(paper_bgcolor='black') %>% 
        layout(plot_bgcolor='black') %>% 
        layout(yaxis = list(tickmode = 'linear',
                            color = 'white',
                            title = "",
                            showgrid = FALSE)) %>% 
        layout(xaxis = list(tickformat = '$)',
                            range = c(0, 100),
                            color = 'white',
                            title = "Revenue (Billions)",
                            tick0 = 0, 
                            dtick = 25,
                            tickmode = 'linear',
                            gridcolor = "#383838")) %>% 
        layout(legend = list(bgcolor = "grey15",
                             font = list(color = "white",
                                         family = "Calibri Light"))) %>% 
        layout(title = "Highest Grossing Media Franchises (plotly)",
               titlefont = list(family = "Calibri Light", size = 20, color = "white",
                                face = "bold"))
    })
}



# Run the application 
shinyApp(ui = ui, server = server)
