library(tidyverse)
library(ggdark)

theme_set(ggdark::dark_theme_minimal(base_size = 22))

errors <- read_csv("./data/predictions/errors.csv") 
store_sales <- read_csv("data/store_demand_clean.csv")

test_date <- min(errors$date)

plot_df <- bind_rows(errors, store_sales) %>% 
  mutate(date = lubridate::ymd(date)) %>% 
  pivot_longer(autoreg:neural_prophet, names_to = "model", values_to = "pred_sales") %>%  
  mutate(model = case_when(
    model == "ardl" ~ "Autoregressive Distributed Lag",
    model == "autoreg" ~ "Vector Autoregression",
    model == "exp_smooth" ~ "Seasonal Exponential Smoothing",
    model == "neural_prophet" ~ "Neural Prophet",
    model == "prophet" ~ "Prophet",
    model == "xgb_preds" ~ "XGBoost Forecast",
  ))

my_saver <- function (name) {
  ggsave(filename = paste0("R/saved_plots/", name, ".png"),
         width = 16, height = 9, dpi = 320)
}

base_plot <- plot_df %>%
  filter(date <= test_date, store_item == "1-1") %>% 
  ggplot((aes(x = date, y = sales))) +
  geom_line(color = "grey44") + 
  expand_limits(y=0) + 
  scale_x_date(
    date_breaks = "7 month",
    date_labels = "%b '%y",
    limits = c(min(store_sales$date), max(store_sales$date))) +
  labs(title = "Daily Sales Training Data", 
       subtitle = " ",
       x = NULL, y = "Units Sold of Product 1 / 500")

base_plot

my_saver("data")

base_plot +
  stat_smooth(se = FALSE, span = 0.1, method = "loess") +
  labs(subtitle = "Observe the Strong Seasonality")

my_saver("seasonality")

base_plot +
  stat_smooth(se = FALSE, method = "lm", color = "red") +
  labs(subtitle = "Notice a Slight Trend")

my_saver("trend")

facets_to_plot <- function(n = 9){
  
  store_items_nine <- plot_df %>% 
    count(store_item) %>% 
    slice(1:50) %>% 
    pull(store_item) %>% 
    gtools::mixedsort(decreasing = TRUE) %>% 
    head(n)
  
  store_items_nine
  
  plot_df %>%
    filter(date <= test_date, store_item %in% store_items_nine) %>% 
    ggplot((aes(x = date, y = sales))) +
    geom_line(color = "grey44") + 
    expand_limits(y=0) + 
    scale_x_date(
      date_breaks = "15 month",
      date_labels = "%b '%y",
      limits = c(min(store_sales$date), max(store_sales$date))) +
    labs(title = "Illustrating the Scale", 
         subtitle = " ",
         x = NULL, y = "Units of Product Sold")
  
}

facets_to_plot() +
  facet_wrap(~store_item)

my_saver("nine_fcts")

facets_to_plot(50) +
  facet_wrap(~store_item, ncol = 10) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

my_saver("fifty_fcts") 

plots_fct <- base_plot +
  geom_point(
    data = subset(plot_df),
    aes(x = date, y = pred_sales), color = "blue", size = 0.25) +
  labs(title = "Daily Sales Point Forecasts") +
  scale_y_continuous(limits = c(0, 50)) + 
  facet_wrap(~model, ncol = 2)+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

plots_fct

my_saver("point_fcast")

plots_fct + 
  geom_line(data = filter(plot_df, date > test_date), 
            aes(x = date, y = sales),
                      color = "darkred", alpha = 0.5) +
  labs(title = "Daily Sales Point Forecasts With Testing Set") 
  
my_saver("point_fcast_test")
