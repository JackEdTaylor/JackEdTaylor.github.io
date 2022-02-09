for (f in list.files(path=".", pattern="\\.md$")) {
  file.remove(f)
}

pubs <- read.csv(
  "pubs.csv",
  na.strings = ""
)

pubs_order <- order(-pubs$year, pubs$peer_reviewed_paper, pubs$authors)
pubs <- pubs[pubs_order, ]
pubs$weight <- rev(1:nrow(pubs))

for (rn in 1:nrow(pubs)) {
  p <- pubs[rn, ]

  key_vals <- sapply(colnames(pubs), function(key) {
    if (!all(is.na(p[[key]]))) sprintf("%s: '%s'", key, p[[key]])
  }) |>
    unlist()

  md_text <- c("---", key_vals, "---")

  first_auth <- strsplit(p$authors, ",", fixed=TRUE)[[1]][1]
  first_word <- strsplit(p$title, "[^a-zA-Z\\d]", fixed=FALSE)[[1]][1]

  file_name <- sprintf("%s_%s_%s.md", p$year, tolower(first_auth), tolower(first_word))

  md_conn <- file(file_name)
  writeLines(md_text, md_conn)
  close(md_conn)
}
