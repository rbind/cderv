## ----simple-plot, fig.alt = "A simple plot with dots", echo = FALSE-----------
plot(1:10)


## ----cars-speed, fig.alt = "A plot about cars' stopping speed vs distance", echo = FALSE----
plot(cars)


## -----------------------------------------------------------------------------
1+1


## ----retrieve-chunk-opt, include= FALSE---------------------------------------
# get all labels from chunk with fig.alt chunk option defined
chunks_with_alt <- knitr::all_labels(nzchar(fig.alt))
# Use these labels to retrieve code content 
chunks_content <- knitr::knit_code$get(chunks_with_alt)
# retrieve specifically chunk options
chunks_opts <- lapply(chunks_content, function(x) attr(x, "chunk_opts"))


## ----write-appendix, results='asis', echo = FALSE-----------------------------
# Looping over the selected chunks
l <- lapply(seq_along(chunks_opts), function(opt_ind) {
  # We use the index number but we need the option content
  opt <- chunks_opts[[opt_ind]]
  knitr::knit_expand(
    # template string to fill in using index...
    text = "* Figure {{opt_ind}} (chunk label '{{label}}'): {{alt_text}}", 
    # and the alt text set...
    alt_text = opt$fig.alt,
    # and the label of the chunk
    label = opt$label)
})
# Using cat() to output the string content to be included as-is.
cat(unlist(l), sep = "\n")

