# script for generating YAML from csv for publications page

path <- file.path("content", "publication")

for (f in list.files(path=path, pattern="\\.md$", full.names=TRUE)) {
  file.remove(f)
}

pubs <- read.csv(
  file.path(path, "pubs.csv"),
  na.strings = ""
)

pubs_order <- order(-pubs$year, pubs$peer_reviewed_paper, pubs$authors)
pubs <- pubs[pubs_order, ]
pubs$weight <- 1:nrow(pubs)

for (rn in 1:nrow(pubs)) {
  p <- pubs[rn, ]

  if (!grepl("[\\.\\?\\!]$", p$title)) {
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
