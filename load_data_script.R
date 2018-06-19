library(tidyverse)


# Load all claims transactions data
data_files <- list.files('data', full.names = TRUE, pattern = '\\.csv')

claims_transactions_tbl <- data_frame(file_src = data_files) %>%
    mutate(data = map(file_src, read_csv, col_types = cols())) %>%
    bind_rows() %>%
    unnest() %>%
    select(-file_src)


claims_snapshot_tbl <- claims_transactions_tbl %>%
    group_by(country_code, claim_id, claim_type) %>%
    top_n(1, wt = transaction_date) %>%
    ungroup() %>%
    mutate(claim_lifetime = as.numeric(transaction_date - incident_date)
          ,yearmonth      = format(incident_date, '%Y%m')
           )
