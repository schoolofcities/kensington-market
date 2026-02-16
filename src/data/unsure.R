# Timeline visualization with scatter plot and S-curved lines - Everything except Grocer and Raw foods
library(jsonlite)
library(plotly)

# Read the data
data <- fromJSON("businesses.geo.json", simplifyVector = FALSE)

# Define year range: 2007 to 2025
start_year <- 2007
end_year <- 2025
all_years <- start_year:end_year

# Assign colors to each type
type_colors <- list(
  "Grocer" = "#26a69a",
  "Raw foods" = "#4dd0e1",
  "Retail" = "#6c46ea",
  "Cannabis store" = "#e1c542",
  "Restaurant" = "#e74c3c",
  "Service" = "#7ea1e6",
  "Vacant" = "#cccccc"
)

# Filter for businesses that start as anything except Grocer or Raw foods
included_addresses <- c()

for (feature in data$features) {
  address <- feature$properties$address
  history <- feature$properties$history
  if (is.null(history) || length(history) == 0) next
  
  # Find the earliest entry (or first entry at/after 2007)
  earliest_entry <- NULL
  for (entry in history) {
    if (!is.null(entry$year) && !is.null(entry$type)) {
      year <- entry$year
      if (year < start_year) year <- start_year
      if (year <= end_year) {
        if (is.null(earliest_entry) || year < earliest_entry$year) {
          earliest_entry <- list(year = year, type = entry$type)
        }
      }
    }
  }
  
  # Include this address if it starts as anything EXCEPT Grocer or Raw foods
  if (!is.null(earliest_entry) && !earliest_entry$type %in% c("Grocer", "Raw foods")) {
    included_addresses <- c(included_addresses, address)
  }
}

cat(sprintf("Found %d businesses that started as types other than Grocer or Raw foods\n", length(included_addresses)))

# Collect all businesses from included addresses
all_businesses <- data.frame(
  year = numeric(),
  name = character(),
  type = character(),
  address = character(),
  stringsAsFactors = FALSE
)

for (feature in data$features) {
  address <- feature$properties$address
  
  # Only process included addresses
  if (!address %in% included_addresses) next
  
  history <- feature$properties$history
  if (is.null(history) || length(history) == 0) next
  
  for (entry in history) {
    if (!is.null(entry$year) && !is.null(entry$name) && !is.null(entry$type)) {
      year <- entry$year
      if (year < start_year) year <- start_year
      if (year <= end_year) {
        all_businesses <- rbind(all_businesses, data.frame(
          year = year,
          name = entry$name,
          type = entry$type,
          address = address,
          stringsAsFactors = FALSE
        ))
      }
    }
  }
}

# Add terminating nodes for businesses that exist before 2025 but don't have a 2025 entry
for (address in unique(all_businesses$address)) {
  business_history <- all_businesses[all_businesses$address == address, ]
  business_history <- business_history[order(business_history$year), ]
  
  # Get the most recent entry
  last_entry <- business_history[nrow(business_history), ]
  
  # If the last entry is before 2025, add a 2025 node
  if (last_entry$year < end_year) {
    all_businesses <- rbind(all_businesses, data.frame(
      year = end_year,
      name = last_entry$name,
      type = last_entry$type,
      address = address,
      stringsAsFactors = FALSE
    ))
  }
}

# For 2007 and 2025, count businesses by type and determine hierarchy
year_type_hierarchy <- list()
for (year in c(start_year, end_year)) {
  year_data <- all_businesses[all_businesses$year == year, ]
  if (nrow(year_data) > 0) {
    type_counts <- table(year_data$type)
    type_counts <- sort(type_counts, decreasing = TRUE)
    year_type_hierarchy[[as.character(year)]] <- names(type_counts)
  }
}

# Assign y-positions
all_businesses$y_pos <- NA

# First, position 2007 businesses (sorted by type hierarchy) with extra spacing
year_2007_idx <- which(all_businesses$year == start_year)
if (length(year_2007_idx) > 0) {
  year_data <- all_businesses[year_2007_idx, ]
  year_data$type_rank <- match(year_data$type, year_type_hierarchy[[as.character(start_year)]])
  year_data <- year_data[order(year_data$type_rank, year_data$name), ]
  
  n_businesses <- nrow(year_data)
  # Increased spacing - use more vertical space
  y_positions <- seq(0.98, 0.02, length.out = n_businesses)
  
  for (i in 1:n_businesses) {
    original_idx <- which(
      all_businesses$year == year_data$year[i] &
        all_businesses$name == year_data$name[i] &
        all_businesses$address == year_data$address[i]
    )
    all_businesses$y_pos[original_idx[1]] <- y_positions[i]
  }
}

# Then, position 2025 businesses (sorted by type hierarchy) with extra spacing
year_2025_idx <- which(all_businesses$year == end_year)
if (length(year_2025_idx) > 0) {
  year_data <- all_businesses[year_2025_idx, ]
  year_data$type_rank <- match(year_data$type, year_type_hierarchy[[as.character(end_year)]])
  year_data <- year_data[order(year_data$type_rank, year_data$name), ]
  
  n_businesses <- nrow(year_data)
  # Increased spacing - use more vertical space
  y_positions <- seq(0.98, 0.02, length.out = n_businesses)
  
  for (i in 1:n_businesses) {
    original_idx <- which(
      all_businesses$year == year_data$year[i] &
        all_businesses$name == year_data$name[i] &
        all_businesses$address == year_data$address[i]
    )
    all_businesses$y_pos[original_idx[1]] <- y_positions[i]
  }
}

# For middle years, position based on interpolation between connected nodes
for (address in unique(all_businesses$address)) {
  business_history <- all_businesses[all_businesses$address == address, ]
  business_history <- business_history[order(business_history$year), ]
  
  if (nrow(business_history) > 1) {
    for (i in 1:nrow(business_history)) {
      if (!is.na(business_history$y_pos[i])) {
        next
      }
      
      prev_idx <- NA
      next_idx <- NA
      
      for (j in (i-1):1) {
        if (!is.na(business_history$y_pos[j])) {
          prev_idx <- j
          break
        }
      }
      
      for (j in (i+1):nrow(business_history)) {
        if (!is.na(business_history$y_pos[j])) {
          next_idx <- j
          break
        }
      }
      
      if (!is.na(prev_idx) && !is.na(next_idx)) {
        total_years <- business_history$year[next_idx] - business_history$year[prev_idx]
        years_from_prev <- business_history$year[i] - business_history$year[prev_idx]
        ratio <- years_from_prev / total_years
        
        interpolated_y <- business_history$y_pos[prev_idx] + 
          ratio * (business_history$y_pos[next_idx] - business_history$y_pos[prev_idx])
        
        original_idx <- which(
          all_businesses$year == business_history$year[i] &
            all_businesses$name == business_history$name[i] &
            all_businesses$address == business_history$address[i]
        )
        all_businesses$y_pos[original_idx[1]] <- interpolated_y
      } else if (!is.na(prev_idx)) {
        all_businesses$y_pos[which(
          all_businesses$year == business_history$year[i] &
            all_businesses$name == business_history$name[i] &
            all_businesses$address == business_history$address[i]
        )[1]] <- business_history$y_pos[prev_idx]
      } else if (!is.na(next_idx)) {
        all_businesses$y_pos[which(
          all_businesses$year == business_history$year[i] &
            all_businesses$name == business_history$name[i] &
            all_businesses$address == business_history$address[i]
        )[1]] <- business_history$y_pos[next_idx]
      }
    }
  }
}

# Function to create S-curved path between two points using cubic Bezier
create_s_curve <- function(x1, y1, x2, y2, n_points = 50) {
  t <- seq(0, 1, length.out = n_points)
  
  cx1 <- x1 + (x2 - x1) * 0.4
  cy1 <- y1
  
  cx2 <- x1 + (x2 - x1) * 0.6
  cy2 <- y2
  
  x <- (1 - t)^3 * x1 + 
    3 * (1 - t)^2 * t * cx1 + 
    3 * (1 - t) * t^2 * cx2 + 
    t^3 * x2
  
  y <- (1 - t)^3 * y1 + 
    3 * (1 - t)^2 * t * cy1 + 
    3 * (1 - t) * t^2 * cy2 + 
    t^3 * y2
  
  return(list(x = x, y = y))
}

# Create the base plot
fig <- plot_ly()

# Add vertical year lines (only dotted lines, no axis lines)
for (year in all_years) {
  fig <- fig %>% add_segments(
    x = year, xend = year,
    y = 0, yend = 1,
    line = list(color = "rgba(150,150,150,0.3)", width = 1, dash = "dot"),
    showlegend = FALSE,
    hoverinfo = "skip"
  )
}

# Add S-curved transition lines for each address
for (address in unique(all_businesses$address)) {
  business_history <- all_businesses[all_businesses$address == address, ]
  business_history <- business_history[order(business_history$year), ]
  
  if (nrow(business_history) > 1) {
    for (i in 1:(nrow(business_history) - 1)) {
      if (!is.na(business_history$y_pos[i]) && !is.na(business_history$y_pos[i + 1])) {
        curve <- create_s_curve(
          business_history$year[i],
          business_history$y_pos[i],
          business_history$year[i + 1],
          business_history$y_pos[i + 1]
        )
        
        fig <- fig %>% add_trace(
          x = curve$x,
          y = curve$y,
          type = "scatter",
          mode = "lines",
          line = list(color = "rgba(150,150,150,0.2)", width = 1),
          showlegend = FALSE,
          hoverinfo = "skip"
        )
      }
    }
  }
}

# Get unique types for legend
unique_types <- unique(all_businesses$type)

# Add points for each business (colored by type)
for (type in unique_types) {
  type_data <- all_businesses[all_businesses$type == type, ]
  if (nrow(type_data) > 0) {
    color <- if (!is.null(type_colors[[type]])) type_colors[[type]] else "#999999"
    
    fig <- fig %>% add_trace(
      data = type_data,
      x = ~year,
      y = ~y_pos,
      type = "scatter",
      mode = "markers+text",
      marker = list(
        size = 3,
        color = color
      ),
      text = ~name,
      textposition = "middle right",
      textfont = list(size = 7, color = color),  # Reduced font size slightly
      name = type,
      hovertemplate = paste(
        "<b>%{text}</b><br>",
        "Year: %{x}<br>",
        "Type: ", type,
        "<extra></extra>"
      )
    )
  }
}

# Layout with increased height to accommodate more spacing
fig <- fig %>% layout(
  title = "Business Transitions: Excluding Grocer and Raw Foods Origins (2007-2025)",
  xaxis = list(
    title = "Year",
    tickmode = "linear",
    tick0 = start_year,
    dtick = 1,
    range = c(start_year - 0.5, end_year + 3.5),
    showgrid = FALSE,
    zeroline = FALSE
  ),
  yaxis = list(
    title = "",
    showticklabels = FALSE,
    showgrid = FALSE,
    zeroline = FALSE,
    range = c(-0.02, 1.02)  # Tighter range to use full space
  ),
  width = 900,
  height = 800,  # Increased height from 600 to 800
  hovermode = "closest",
  paper_bgcolor = "white",
  plot_bgcolor = "white",
  margin = list(l = 50, r = 200, t = 50, b = 50)
)

# Display
fig

# Optionally save to HTML
# htmlwidgets::saveWidget(fig, "non_grocer_rawfoods_transitions.html", selfcontained = TRUE)