# R4DS-TidyTuesday

# 2019-07-02 Media Franchise Revenues 📖🎞️🕹️
![media_franchises](https://user-images.githubusercontent.com/35606112/62182308-c27d6f00-b31b-11e9-9db3-31674d29c5bb.png)

### About the viz

On r/dataisbeautiful, reddit user /u/takeasecond posted a visualization on the highest grossing media franchises using data scraped from wikipedia. Following soon after, the R4DS online community posted the data set for their TidyTuesday, a weekly project aimed at making useful visualizations using ggplot, tidyr, dplyr, and other tools within the tidyverse ecosystem. David Robinson (Chief Data Scientist at DataCamp) posted his data exploration of the data set on a screencast where he reproduced the graph of the highest grossing franchises. I polished Robinson's ggplot graph to more closely resemble /u/takeasecond's graph and produced a plot_ly version of the graph; these are embedded here into an web application to make it interactive using plotly and shiny.

### Alternative Viz (Shiny -- ggplot/plotly, Tableau)

##### Shiny (ggplot/plotly)
https://benjnguyen.shinyapps.io/Franchise-Shiny/

##### Tableau
A rudimentary graph was also created in Tableau -- with some effort, it could be well-polished too.

https://public.tableau.com/profile/benjamin3862#!/vizhome/MediaFranchisesCoordFlip/Sheet1?publish=yes

##### Comments on alternative viz
Functionally, the legend filter works like ggplotly's legend filter -- which is not exactly intuitive.
Plotly's interactive legend does what I would expect -- it collapses the stacked bars onto its respective axis.
The plotly graph can be seen in the shiny application 'Franchise-Shiny'. 

However, in Tableau, if the 'exclude' option
is used in the legend, it will re-calculate the graphs, filtering for the remaining revenue streams. I still have to figure that out in ggplot and plotly, but admittedly it is a very handy feature. It would have to be an event handler (i.e. observeEvent()) that finds out what revenue stream has been selected so I can filter out the revenue category from the data and reproduce the graph.
