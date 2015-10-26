source("cleaned.R")
source("Leaflet_REE_deposits_by_country_map_elements.R")
source("Leaflet_REE_elements_by_location.R")

shinyServer(function(input, output, session) {

  output$map <- renderLeaflet({
    pal <- colorFactor(rev(heat.colors(80)), world$projects)
    
    world_popup <- paste0("<strong>Country: </strong>", 
                          world$name, 
                          "<br><strong>", 
                          "Projects", 
                          ": </strong>", 
                          world$projects
                          
    ) 
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(data = world) %>%
      addTiles(urlTemplate = tiles,  
               attribution = attribution) %>%
      setView(0, 0, zoom = 2) %>%
      addPolygons(fillColor = ~pal(world$projects), 
                  fillOpacity = 0.8, 
                  color = "#000000", 
                  weight = 1, 
                  popup = world_popup)
    
  })
  
  
  observe({
  pal <- colorFactor("Paired", domain = new_list5)
    
    leafletProxy("map", data = q2) %>% 
      addCircleMarkers(radius = 3, weight = 1, color = 'black', stroke = FALSE, fillOpacity = 0.5,
                       popup = q2$Element, group = q2$Element) %>% addLayersControl(
                         #~pal(Element) use that for colors
                         overlayGroups = q2$Element,
                         options = layersControlOptions(collapsed = FALSE)
                         
                         #Note:  use ~pal(Element) to colorcode elements
                       ) 

  })
  
  # Incremental changes to the map should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  #the option below did not work:
  
  #observe({
    #leafletProxy(("map"), data = filteredData()) %>%
      #clearMarkers() %>%
      #addCircleMarkers(radius = 5, weight = 1, color = ~pal, stroke = FALSE, fillOpacity = 0.5
      #popup = q2$Element
      #)
 # })
  
 
}
)
