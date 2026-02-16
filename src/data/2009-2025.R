# Timeline visualization with straight lines - Ever Grocer or Raw foods
# SIMPLE VERSION: 2009 and 2025 only, ranked by type count
library(jsonlite)
library(plotly)
library(htmlwidgets)

# Read the data
data <- fromJSON("businesses.geo.json", simplifyVector = FALSE)

# Define years
selected_years <- c(2009, 2025)

# Assign colors to each type and subtype
type_colors <- list(
  "Grocer - Dry goods" = "#26a69a",      # Original teal
  "Grocer - Produce" = "#1a8078",        # Darker teal
  "Grocer - Supermarket" = "#33c9ba",    # Lighter teal
  "Raw foods" = "#4dd0e1",
  "Retail" = "#6c46ea",
  "Cannabis store" = "#e1c542",
  "Restaurant" = "#e74c3c",
  "Service" = "#7ea1e6",
  "Vacant" = "#cccccc"
)

# Filter for businesses that are Grocer or Raw foods in 2009 or 2025
included_addresses <- c()

for (feature in data$features) {
  address <- feature$properties$address
  history <- feature$properties$history
  if (is.null(history) || length(history) == 0) next
  
  # Check if the business is a Grocer or Raw foods in 2009 or 2025
  has_grocer_or_raw_in_target_years <- FALSE
  
  for (target_year in selected_years) {
    # Find the most recent entry at or before this year
    valid_entries <- data.frame(
      year = numeric(),
      type = character(),
      stringsAsFactors = FALSE
    )
    
    for (entry in history) {
      if (!is.null(entry$year) && !is.null(entry$type) && entry$year <= target_year) {
        valid_entries <- rbind(valid_entries, data.frame(
          year = entry$year,
          type = entry$type,
          stringsAsFactors = FALSE
        ))
      }
    }
    
    if (nrow(valid_entries) > 0) {
      valid_entries <- valid_entries[order(valid_entries$year, decreasing = TRUE), ]
      current_type <- valid_entries$type[1]
      
      if (current_type %in% c("Grocer", "Raw foods")) {
        has_grocer_or_raw_in_target_years <- TRUE
        break
      }
    }
  }
  
  if (has_grocer_or_raw_in_target_years) {
    included_addresses <- c(included_addresses, address)
  }
}

cat(sprintf("Found %d businesses that are Grocer or Raw foods in 2009 or 2025\n", length(included_addresses)))

# Build complete history for all businesses (considering ALL data)
complete_history <- list()

for (feature in data$features) {
  address <- feature$properties$address
  
  # Only process included addresses
  if (!address %in% included_addresses) next
  
  history <- feature$properties$history
  if (is.null(history) || length(history) == 0) next
  
  # Store complete history for this address
  address_history <- data.frame(
    year = numeric(),
    name = character(),
    type = character(),
    subtype = character(),
    stringsAsFactors = FALSE
  )
  
  for (entry in history) {
    if (!is.null(entry$year) && !is.null(entry$name) && !is.null(entry$type)) {
      subtype <- if (!is.null(entry$subtype)) entry$subtype else ""
      
      address_history <- rbind(address_history, data.frame(
        year = entry$year,
        name = entry$name,
        type = entry$type,
        subtype = subtype,
        stringsAsFactors = FALSE
      ))
    }
  }
  
  # Sort by year
  address_history <- address_history[order(address_history$year), ]
  complete_history[[address]] <- address_history
}

# Now create snapshots for each selected year
all_businesses <- data.frame(
  year = numeric(),
  name = character(),
  type = character(),
  subtype = character(),
  display_type = character(),
  address = character(),
  stringsAsFactors = FALSE
)

for (address in names(complete_history)) {
  address_history <- complete_history[[address]]
  
  # For each selected year, find what the business was at that time
  for (target_year in selected_years) {
    # Find the most recent entry at or before this year
    valid_entries <- address_history[address_history$year <= target_year, ]
    
    if (nrow(valid_entries) > 0) {
      # Get the most recent entry
      valid_entries <- valid_entries[order(valid_entries$year, decreasing = TRUE), ]
      current_state <- valid_entries[1, ]
      
      # Create display_type
      display_type <- if (current_state$type == "Grocer" && current_state$subtype != "") {
        paste0("Grocer - ", current_state$subtype)
      } else {
        current_state$type
      }
      
      # Add this snapshot
      all_businesses <- rbind(all_businesses, data.frame(
        year = target_year,
        name = current_state$name,
        type = current_state$type,
        subtype = current_state$subtype,
        display_type = display_type,
        address = address,
        stringsAsFactors = FALSE
      ))
    }
  }
}

# Assign y-positions: for each year, sort by type count (most numerous on top)
all_businesses$y_pos <- NA

for (year in selected_years) {
  year_data <- all_businesses[all_businesses$year == year, ]
  
  if (nrow(year_data) > 0) {
    # Count businesses by display_type for this year
    type_counts <- table(year_data$display_type)
    type_counts <- sort(type_counts, decreasing = TRUE)
    type_hierarchy <- names(type_counts)
    
    cat(sprintf("\n%d type hierarchy (most to least):\n", year))
    for (i in 1:length(type_hierarchy)) {
      cat(sprintf("  %d. %s: %d businesses\n", i, type_hierarchy[i], type_counts[type_hierarchy[i]]))
    }
    
    # Assign type rank based on count (most numerous = rank 1)
    year_data$type_rank <- match(year_data$display_type, type_hierarchy)
    
    # For businesses in the same type, sort by destination/source or name
    if (year == selected_years[1]) {
      # First year: sort by type rank, then by where they're going, then name
      year_data$next_type <- NA
      for (i in 1:nrow(year_data)) {
        business_history <- all_businesses[all_businesses$address == year_data$address[i], ]
        business_history <- business_history[order(business_history$year), ]
        if (nrow(business_history) > 1) {
          year_data$next_type[i] <- business_history$display_type[nrow(business_history)]
        } else {
          year_data$next_type[i] <- year_data$display_type[i]
        }
      }
      year_data <- year_data[order(year_data$type_rank, year_data$next_type, year_data$name), ]
      
      # MANUAL OVERRIDE: Move Zimmerman's Fairland to bottom of ALL Grocer types
      zimm_idx <- which(grepl("Zimmerman.*Fairland", year_data$name, ignore.case = TRUE))
      if (length(zimm_idx) > 0) {
        all_grocers <- which(grepl("^Grocer", year_data$display_type))
        if (length(all_grocers) > 0) {
          target_position <- max(all_grocers)
          if (zimm_idx != target_position) {
            zimm_row <- year_data[zimm_idx, ]
            year_data <- year_data[-zimm_idx, ]
            if (zimm_idx < target_position) {
              target_position <- target_position - 1
            }
            if (target_position >= nrow(year_data)) {
              year_data <- rbind(year_data, zimm_row)
            } else {
              year_data <- rbind(
                year_data[1:target_position, ],
                zimm_row,
                year_data[(target_position + 1):nrow(year_data), ]
              )
            }
          }
        }
      }
      
    } else {
      # Last year: sort by type rank, then by where they came from, then name
      year_data$start_y <- NA
      for (i in 1:nrow(year_data)) {
        business_history <- all_businesses[all_businesses$address == year_data$address[i], ]
        business_history <- business_history[order(business_history$year), ]
        if (nrow(business_history) > 1) {
          start_idx <- which(
            all_businesses$year == business_history$year[1] &
              all_businesses$address == year_data$address[i]
          )[1]
          if (!is.na(start_idx) && !is.na(all_businesses$y_pos[start_idx])) {
            year_data$start_y[i] <- all_businesses$y_pos[start_idx]
          } else {
            year_data$start_y[i] <- 0.5
          }
        } else {
          year_data$start_y[i] <- 0.5
        }
      }
      year_data <- year_data[order(year_data$type_rank, -year_data$start_y, year_data$name), ]
    }
    
    # Assign y-positions (top to bottom: 0.95 to 0.05)
    n_businesses <- nrow(year_data)
    y_positions <- seq(0.95, 0.05, length.out = n_businesses)
    
    for (i in 1:n_businesses) {
      original_idx <- which(
        all_businesses$year == year_data$year[i] &
          all_businesses$name == year_data$name[i] &
          all_businesses$address == year_data$address[i]
      )[1]
      all_businesses$y_pos[original_idx] <- y_positions[i]
    }
  }
}

# Create the base plot
fig <- plot_ly()

# Add vertical year lines
for (year in selected_years) {
  fig <- fig %>% add_segments(
    x = year, xend = year,
    y = 0, yend = 1,
    line = list(color = "rgba(150,150,150,0.3)", width = 1, dash = "dot"),
    showlegend = FALSE,
    hoverinfo = "skip"
  )
}

# Add straight transition lines for each address
for (address in unique(all_businesses$address)) {
  business_data <- all_businesses[all_businesses$address == address, ]
  business_data <- business_data[order(business_data$year), ]
  
  if (nrow(business_data) == 2) {
    # Draw straight line from first to last
    start_data <- business_data[1, ]
    end_data <- business_data[2, ]
    
    # Get the color of the source display_type
    line_color <- "rgba(0,0,0,1)"  # Black with 30% opacity
    
    # Lines connect directly from dot to dot (no text offset needed)
    fig <- fig %>% add_segments(
      x = start_data$year,
      xend = end_data$year,
      y = start_data$y_pos,
      yend = end_data$y_pos,
      line = list(color = line_color, width = 0.2, dash="dot"),
      showlegend = FALSE,
      hoverinfo = "skip"
    )
  }
}

# Get unique display_types for legend
unique_types <- unique(all_businesses$display_type)

# Add points for each business (colored by display_type)
# Split by year to apply different text positions
for (display_type in unique_types) {
  type_data <- all_businesses[all_businesses$display_type == display_type, ]
  if (nrow(type_data) > 0) {
    color <- if (!is.null(type_colors[[display_type]])) type_colors[[display_type]] else "#999999"
    
    # 2009 data - text on LEFT (right-justified to the dot)
    data_2009 <- type_data[type_data$year == 2009, ]
    if (nrow(data_2009) > 0) {
      fig <- fig %>% add_trace(
        data = data_2009,
        x = ~year,
        y = ~y_pos,
        type = "scatter",
        mode = "markers+text",
        marker = list(
          size = 3,
          color = color
        ),
        text = ~name,
        textposition = "middle left",
        textfont = list(size = 8, color = color),
        name = display_type,
        legendgroup = display_type,
        showlegend = FALSE,
        hovertemplate = paste(
          "<b>%{text}</b><br>",
          "Year: %{x}<br>",
          "Type: ", display_type,
          "<extra></extra>"
        )
      )
    }
    
    # 2025 data - text on RIGHT
    data_2025 <- type_data[type_data$year == 2025, ]
    if (nrow(data_2025) > 0) {
      fig <- fig %>% add_trace(
        data = data_2025,
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
        textfont = list(size = 8, color = color),
        name = display_type,
        legendgroup = display_type,
        showlegend = FALSE,
        hovertemplate = paste(
          "<b>%{text}</b><br>",
          "Year: %{x}<br>",
          "Type: ", display_type,
          "<extra></extra>"
        )
      )
    }
  }
}

# Layout
fig <- fig %>% layout(
  xaxis = list(
    title = "Year",
    tickmode = "array",
    tickvals = selected_years,
    ticktext = as.character(selected_years),
    range = c(2009 - 3, 2025 + 3.5),
    showgrid = FALSE,
    zeroline = FALSE
  ),
  yaxis = list(
    title = "",
    showticklabels = FALSE,
    showgrid = FALSE,
    zeroline = FALSE,
    range = c(-0.05, 1.05)
  ),
  width = 600,
  height = 600,
  hovermode = "closest",
  paper_bgcolor = "white",
  plot_bgcolor = "white",
  margin = list(l = 250, r = 250, t = 50, b = 50),
  showlegend = FALSE
)

# Add SVG download button to the config
fig <- fig %>% config(
  toImageButtonOptions = list(
    format = "svg",
    filename = "business_transitions_2009_2025"
  )
)

# Display
print(fig)

# Optionally save to HTML
saveWidget(fig, "business_transitions_2009_2025.html", selfcontained = TRUE)