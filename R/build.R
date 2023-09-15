# script for generating YAML from csv for publications page

message("Generating publications list …")

# library(dplyr)  # for lag() function

# first, remove old folders
file.path("docs", "publication") |>
  dir(pattern="\\d\\_\\d{4}.*", full.names=TRUE) |>
  unlink(recursive=TRUE)

# now, rebuild publications from the csv
path <- file.path("content", "publication")

for (f in list.files(path=path, pattern="\\.md$", full.names=TRUE)) {
  file.remove(f)
}

pubs <- read.csv(
  file.path(path, "pubs.csv"),
  na.strings = ""
)

pubs$is_first_author <- substr(pubs$authors, 0, 6) == "Taylor"

pubs_order <- order(-pubs$year, is.na(pubs$peer_reviewed_article), -pubs$is_first_author, pubs$authors)
pubs <- pubs[pubs_order, ]
pubs$weight <- 1:nrow(pubs)

pubs$year_heading <- ifelse(pubs$year != dplyr::lag(pubs$year), pubs$year, NA)
pubs$year_heading[1] <- pubs$year[1]

for (rn in 1:nrow(pubs)) {
  p <- pubs[rn, ]

  if (p$title=="" | is.na(p$title)) {
    p$title <- ""
  } else if (!grepl("[\\.\\?\\!]$", p$title)) {
    p$title <- sprintf("%s.", p$title)
  }

  non_weight_cols <- colnames(pubs)[colnames(pubs)!="weight"]

  key_vals <- sapply(non_weight_cols, function(key) {
    if (!all(is.na(p[[key]]))) sprintf("%s: '%s'", key, p[[key]])
  }) |>
    unlist()

  weight_val <- sprintf("weight: %g", p$weight)

  md_text <- c("---", key_vals, weight_val, "---")

  first_auth <- strsplit(p$authors, "[, ]", fixed=FALSE)[[1]][1]

  first_word <- strsplit(p$title, "[^a-zA-Z\\d]", fixed=FALSE)[[1]][1]

  file_name <- sprintf("%s_%s_%s_%s.md", p$weight, p$year, tolower(first_auth), tolower(first_word))

  md_conn <- file(file.path(path, file_name))
  writeLines(md_text, md_conn)
  close(md_conn)
}

message("Finished generating publications list …")
