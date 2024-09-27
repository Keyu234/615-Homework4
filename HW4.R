library(data.table)
library(ggplot2)
library(dplyr)
library(lubridate)
#
setwd("C:/Users/16597/Downloads")
#
read.csv("Rainfall.csv", header = TRUE)
file_root <- "https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
tail <- ".txt.gz&dir=data/historical/stdmet/"

final <- data.table()

for (year in 1985:2023) {
  path <- paste0(file_root, year, tail)
  header <- scan(path, what = 'character', nlines = 1, quiet = TRUE)
  skip_lines <- ifelse(year >= 2007, 2, 1)
  buoy_data <- fread(path, header = FALSE, skip = skip_lines, fill=Inf)
  actual_col_count <- ncol(buoy_data)
  header_col_count <- length(header)
  
  if (header_col_count > actual_col_count) {
    header <- header[1:actual_col_count]
  } else if (header_col_count < actual_col_count) {
    header <- c(header, paste0("V", (header_col_count + 1):actual_col_count))
  }
  
  setnames(buoy_data, header)
  buoy_data$Year <- year
  buoy_data$Date <- make_datetime(
    year = buoy_data$YY + ifelse(buoy_data$YY >= 50, 1900, 2000),  
    month = buoy_data$MM,
    day = buoy_data$DD,
    hour = buoy_data$hh,
  )
  
  final <- rbind(final, buoy_data, fill = TRUE)
}
final