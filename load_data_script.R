library(tidyverse)
library(feather)
library(scales)


# Load all claims transactions data
data_files <- list.files('data', full.names = TRUE, pattern = '\\.csv')

claim_transactions_tbl <- tibble(file_src = data_files) %>%
    mutate(data = map(file_src, read_csv, col_types = cols())) %>%
    bind_rows() %>%
    unnest() %>%
    select(-file_src) %>%
    mutate(claim_lifetime = as.numeric(transaction_date - incident_date)
          ,yearmonth      = format(incident_date, '%Y%m')
    )


claim_snapshot_tbl <- claim_transactions_tbl %>%
    group_by(country_code, claim_id, claim_type) %>%
    top_n(1, wt = transaction_date) %>%
    ungroup()


claim_triangles_tbl <- read_feather('data/yearly_triangles.feather')
