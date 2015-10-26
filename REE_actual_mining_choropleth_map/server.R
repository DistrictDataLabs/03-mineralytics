source("Parsing_mining_data.R")
source("Leaflet_mines_top_projects_by_country.R")

shinyServer(function(input, output, session) {
  
  output$map <- renderLeaflet({
    pal <- colorFactor(rev(heat.colors(80)), world$projects)
    #Pop up: The info displayed when click on a country
    world_popup <- paste0("<strong>Country: </strong>", 
                          world$name, 
                          "<br><strong>", 
                          "Total REE Production (metric tons)", 
                          ": </strong>", 
                          world$MT_metric_tons,
                          "<br><strong>", 
                          "Top 5 Projects", 
                          ": </strong><br>",
                          world$top5
    )
    
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(data = world) %>%
      addTiles(urlTemplate = tiles,  
               attribution = attribution) %>%
      setView(0, 0, zoom = 2) %>%
      addPolygons(fillColor = ~pal(world$MT_metric_tons), 
                  fillOpacity = 0.8, 
                  color = "#000000", 
                  weight = 1, 
                  popup = world_popup)
  
    
  })

  
  #only use this observer if you want to add geocoded locations of actual mines
  #observe({
    #leafletProxy("map", data = my_mines_codes) %>%
      #addCircleMarkers(radius = 5, weight = 1, color = 'black', stroke = FALSE, fillOpacity = 0.5,
                       #popup = my_mines_codes$Project
                                            # ) 
  #})

 
}
)
