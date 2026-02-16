# Sankey diagram showing business type transitions from 2007 onwards
library(jsonlite)
library(plotly)

# Read the data
data <- fromJSON("businesses.geo.json", simplifyVector = FALSE)

# Define year range: 2007 to 2025
start_year <- 2007
end_year <- 2025
all_years <- start_year:end_year

cat(sprintf("Analyzing years: %d to %d\n", start_year, end_year))

# Get all unique business types
all_types <- c()
for (feature in data$features) {
  history <- feature$properties$history
  if (!is.null(history)) {
    for (entry in history) {
      if (!is.null(entry$type)) {
        all_types <- c(all_types, entry$type)
      }
    }
  }
}
all_types <- sort(unique(all_types))

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

# Create nodes: one for each (year, type) combination
node_labels <- c()
node_colors <- c()
node_map <- list()
node_index <- 0

for (year in all_years) {
  for (type in all_types) {
    node_name <- paste(year, type)
    node_labels <- c(node_labels, node_name)
    
    # Get color for this type
    color <- if (!is.null(type_colors[[type]])) type_colors[[type]] else "#999999"
    node_colors <- c(node_colors, color)
    
    node_map[[node_name]] <- node_index
    node_index <- node_index + 1
  }
}

# Build links by tracking each business through time
link_sources <- c()
link_targets <- c()
link_values <- c()
transition_counts <- list()

for (feature in data$features) {
  history <- feature$properties$history
  if (is.null(history) || length(history) == 0) next
  
  # Build a map of year -> type for this business
  # Treat any year before 2007 as 2007
  year_type <- list()
  for (entry in history) {
    if (!is.null(entry$year) && !is.null(entry$type)) {
      year <- entry$year
      # Clamp years before 2007 to 2007
      if (year < start_year) {
        year <- start_year
      }
      # Only include years up to end_year
      if (year <= end_year) {
        year_type[[as.character(year)]] <- entry$type
      }
    }
  }
  
  # Skip businesses with no data in our year range
  if (length(year_type) == 0) next
  
  # Fill in missing years with previous type (forward fill)
  for (i in seq_along(all_years)) {
    year_str <- as.character(all_years[i])
    if (!year_str %in% names(year_type) && i > 1) {
      # Find the most recent previous year that has data
      for (j in (i-1):1) {
        prev_year_str <- as.character(all_years[j])
        if (prev_year_str %in% names(year_type)) {
          year_type[[year_str]] <- year_type[[prev_year_str]]
          break
        }
      }
    }
  }
  
  # Create transitions between consecutive years
  for (i in 2:length(all_years)) {
    prev_year <- as.character(all_years[i-1])
    curr_year <- as.character(all_years[i])
    
    if (prev_year %in% names(year_type) && curr_year %in% names(year_type)) {
      prev_type <- year_type[[prev_year]]
      curr_type <- year_type[[curr_year]]
      
      source_name <- paste(all_years[i-1], prev_type)
      target_name <- paste(all_years[i], curr_type)
      
      source_idx <- node_map[[source_name]]
      target_idx <- node_map[[target_name]]
      
      transition_key <- paste(source_idx, target_idx, sep = "-")
      if (is.null(transition_counts[[transition_key]])) {
        transition_counts[[transition_key]] <- 0
      }
      transition_counts[[transition_key]] <- transition_counts[[transition_key]] + 1
    }
  }
}

# Convert transition counts to link vectors
for (key in names(transition_counts)) {
  parts <- strsplit(key, "-")[[1]]
  link_sources <- c(link_sources, as.integer(parts[1]))
  link_targets <- c(link_targets, as.integer(parts[2]))
  link_values <- c(link_values, transition_counts[[key]])
}

cat(sprintf("Total nodes: %d\n", length(node_labels)))
cat(sprintf("Total links: %d\n", length(link_sources)))

# Create Sankey diagram with Plotly
fig <- plot_ly(
  type = "sankey",
  orientation = "h",
  node = list(
    label = node_labels,
    color = node_colors,
    pad = 15,
    thickness = 20,
    line = list(color = "black", width = 0.5)
  ),
  link = list(
    source = link_sources,
    target = link_targets,
    value = link_values,
    color = "rgba(200,200,200,0.4)"
  )
)

fig <- fig %>% layout(
  title = "Business Type Transitions in Kensington Market (2007-2025)",
  font = list(size = 10),
  width = 1600,
  height = 800
)

# Display
fig

# Optionally save to HTML
# htmlwidgets::saveWidget(fig, "business_transitions_2007_2025.html", selfcontained = TRUE)