library(tidyverse)
  theme_set(papaja::theme_apa(base_size = 15))

store_sales <- read_csv("data/store_demand_clean.csv")
store_sales %>% 
  filter(store_item %in% c("1-1", "1-2","1-3", "1-4")) %>% 
  ggplot(aes(x = date, y = sales)) +
  geom_line() + 
  stat_smooth(span = 0.15, method = "loess", color = "grey55", se = FALSE) + 
  facet_wrap(~store_item, scales = "free", nrow = 2) +
  annotate("rect", 
           xmin = lubridate::ymd("2016-07-01"),
           xmax = lubridate::ymd("2018-01-01"),
           ymin = 0, ymax = Inf,
           alpha = .2) + 
  labs(title = NULL, x = NULL, y = "Units Sold",
       caption = "The task is to generate high quality\nforecasts for 500 series sililar to these",
       subtitle = "Testing Set") + 
  theme(plot.subtitle = element_text(hjust = 1, face= "italic"))

ggsave("report/plots/item_sales.png", width = 8, height = 6)

tibble::tibble(Model = c("FB Prophet", "ARDL", "Neural Prophet", "Exponential Smoothing", "Autoregression", "Xgboost"),
              `Test Set Performance` = c(12.89, 16.83, 18.44, 19.31, 23.93, 30.35),
              `Aggrigated Weekly` = c(7.33, 8.94, 10.46, 14.88, 17.51, 28.85),
              `Aggrigated Monthly` =c(4.24, 4.48, 7.61, 13.54, 16.25, 28.43)

) %>% 
  as.data.frame() %>% 
  stargazer::stargazer(summary=FALSE, rownames=FALSE) 

errors <- 
  read_csv("data/predictions/errors.csv")

error_df <- errors %>% 
  filter(date >= lubridate::ymd("2016-07-01")) %>% 
  select(autoreg:neural_prophet) %>% 
  map_df(~.x - errors$sales) %>% 
  pivot_longer(cols = autoreg:neural_prophet, names_to = "model", values_to = "abs_error") %>% 
  mutate(model = case_when(
    model == "ardl" ~ "AR Distributed Lag",
    model == "autoreg" ~ "Vector Autoreg",
    model == "exp_smooth" ~ "Exponential Smoothing",
    model == "neural_prophet" ~ "Neural Prophet",
    model == "prophet" ~ "Prophet",
    model == "xgb_preds" ~ "XGBoost Forecast",
  ))

error_df %>% nrow()
error_df %>% 
  ggplot(aes(x = abs_error)) +
  geom_histogram(bins = 250, alpha = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed") + 
  scale_x_continuous(limits = c(-75, 75)) + 
  facet_wrap(~model, ncol = 2) + 
  labs(x = "Absolute Error", y = NULL)

ggsave("report/plots/errors.png", width = 8, height = 8)


error_df %>% 
  group_by(model) %>% 
  summarise(median = median(abs_error),
            std = sd(abs_error),
            x_05 = quantile(abs_error, 0.05),
            x_95 = quantile(abs_error, 0.95),
            
            )  %>% 
  as.data.frame() %>% 
  stargazer::stargazer(summary=FALSE, rownames=FALSE) 
  
