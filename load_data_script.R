library(tidyverse)


# Load all claims transactions data
data_files <- list.files('data', full.names = TRUE, pattern = '\\.csv')

claims_transactions_tbl <- data_frame(file_src = data_files) %>%
    mutate(data = map(file_src, read_csv, col_types = cols())) %>%
    bind_rows() %>%
    unnest() %>%
    select(-file_src)
