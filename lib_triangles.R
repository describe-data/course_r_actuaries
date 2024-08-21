

construct_claim_triangles <- function(tnxdata_tbl,
  origin_type = "uwyear", dev_period = "qtr", fin_type = "paid",
  agg_type = "incr", as_at = as.Date("2016-12-31")) {

  ### First we exclude any transactions from after the as_at date
  use_tnxdata_tbl <- tnxdata_tbl |>
    filter(transaction_date <= as_at)


  ### We need to setup the development periods used. To make things simple, we
  ### calculate everything in months and then set a multiplier for this, 1 for
  ### monthly, 3 for quarterly and 12 for annual.
  if(dev_period == "ann") {
    month_mult <- 12
  } else if(dev_period == "qtr") {
    month_mult <- 3
  } else {
    month_mult <- 1
  }


  ### We now want to determine the maximum number of development periods.
  ### Our origin year is going to be the same regardless of this value.
  if(origin_type == "uwyear") {
    origin_col <- "year"
  } else {
    origin_col <- "year"   ### Including to illustrate the idea
  }

  ### We now create a new column 'origin_year' which is the appropriate column
  use_tnxdata_tbl <- use_tnxdata_tbl |>
    mutate(origin_year = .data[[origin_col]])

  ### We calculate the number of months between the first origin date and the
  ### most recent date.
  start_date <- use_tnxdata_tbl |>
    pull(origin_year) |>
    min() |>
    str_c("-12-31") |>
    as.Date()


  dev_period_interval <- interval(start_date, as_at)

  max_month_count <- (dev_period_interval / dmonths(1))

  max_dev_period <- max_month_count |>
    divide_by(month_mult) |>
    ceiling()


  ### We now use a similar calculation to assign a development period to each
  ### date
  use_tnxdata_tbl <- use_tnxdata_tbl |>
    mutate(
      dev_period = map2_int(
        origin_year, transaction_date,

        \(x, y) calculate_development_period(x, y, month_mult = month_mult),

        .progress = "calc_dev_period"
        )
      )


  claim_dev_periods_tbl <- use_tnxdata_tbl |>
    count(
      origin_year, claim_id, dev_period,
      wt   = amount,
      name = "amount"
      )


  if(agg_type == "incr") {
    output_dev_period_tbl <- claim_dev_periods_tbl |>
      mutate(
        agg_type = agg_type,

        .before = amount
        )

  } else {
    output_dev_period_tbl <- claim_dev_periods_tbl |>
      group_by(origin_year, claim_id) |>
      arrange(dev_period) |>
      mutate(
        amount   = cumsum(amount),
        agg_type = agg_type,

        .before = amount
        ) |>
      ungroup() |>
      arrange(origin_year, claim_id, dev_period)
  }

  return(output_dev_period_tbl)
}


calculate_development_period <- function(origin_label, tnx_date, month_mult) {

  origin_date <- origin_label |>
    str_c("-12-31") |>
    as.Date()

  dev_period_interval <- interval(origin_date, tnx_date)

  dev_period <- dev_period_interval |>
    divide_by(dmonths(1)) |>
    divide_by(month_mult) |>
    ceiling() |>
    pmax(0)

  return(dev_period)
}

