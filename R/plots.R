library(tidyverse)

errors <- read_csv("./data/predictions/errors.csv", )
store_sales <- read_csv("data/store_demand_clean.csv")

test_date <- min(errors$date)

plot_df <- bind_rows(errors, store_sales) %>% 
  filter(store_item == "1-1") %>% 
  pivot_longer(autoreg:neural_prophet, names_to = "model", values_to = "pred_sales")

base_plot <- plot_df %>%
  ggplot((aes(x = date, y = sales))) +
  geom_line()

base_plot +
  stat_smooth(se = FALSE, span = 0.1, method = "loess")

base_plot +
  stat_smooth(se = FALSE, method = "lm", color = "red") 

plot_df %>% 
  filter(date <= test_date) %>% 
  ggplot((aes(x = date, y = sales))) +
  geom_line() +
  xlim(min(store_sales$date), max(store_sales$date))

