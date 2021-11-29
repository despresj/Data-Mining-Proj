# Project Report
# Authors
# Introduction

The goal of this project is to combine various forecasting methods and generate ensamble predictions more accurate than individual algorythms. The ability to generate accurate forecasts is of great interest to many types of organiations. Governments, businesses, and non-profit organizations all forced to make forecasts when planning their various activities. The purpose of this project is to show that certain combinations of forecasts (ensamble) are more accurate than any given method on their own.

# Data

The data obtained for this project are provided as part of a kaggle challenge which we are participating. The competeition challenges participants to forecast daily retail sales demand (https://www.kaggle.com/c/demand-forecasting-kernels-only). As contestents, we are given 5 years of training data, with the daily sales of 50 different products from ten different stores. This is a total of 913,000 data points to train forecasting models. The goal is to forecast the next 90 days for each of the 50 products and 10 stores. Judged by Mean Absolute Scaled Error (MASE)

The data required very little preparation. There were several datapoints that were zero we switched to a one because the statsmodels implimentzation of vector autoregression did not support zero values. We only did that once. After that we combined the stores and items into one string column to avoid nesting loops when iterationg over stores and items.

EXPLOATORY PLOTS AND DESCRIPTIVE STATISTICS
These data are highly seasonal with a slight upwared trend. These data have significant noise. the vast majority of data involving human activities have a seasonal and trend component (https://www.youtube.com/watch?v=pOYAXv15r3A). 

After that, we seperated into a training and testing partitians to test. We used the first 1279 (80%) of our timeseries. Then we seperated the remainder of the data as a testing set. This prepares us for running the experiments.

# Experiments

The project will use that clean data and input it into a feature detection algorythm which quantifies various features of each series. Then Takes the data and runs six different forecasting algorythms to generate a prediction for the remainder of the testing data. Then analyze forecasting errors. Then attempt to use machiene learning methods to select the best model for the data given features

FLOW CHART

## Running Multiple Forecast Models

Although there are many forecasting models to choose from, there is not much research on when a given forecasting model outperforms another. This is an open field and we are going to test different ones and evaluate them strictly on their perfromance on testing data. 

### Vector Auto Regression

The first algorythm we impliment, this takes the first 5 lag positions and uses them as regressors, then using timeseries decomposition, it models the seasonality. This model is commonly used to forecast economic variables. 

### Exponential Smoothing

### Auto Regressive Distributed Lag

### XGBoost

### Facebook's Prophet

### Neuro Prophet

This is a very similar idea to prophet, however the parameters are fit using a neural network.

## Feature Detection

There are many different shapes and patterns a timerseries plot can take. Tsfeatures (https://cran.r-project.org/web/packages/tsfeatures/vignettes/tsfeatures.html) quantifies different features such as the number of times it crosses the median, degree of seasonality, the number of flat spots, entropy, and many more. 

We ran this algorythm on each series collecting 30 quantified features. The central question of this study is to determine if we can determine which forecast will perfrom the best given these features. 

## Predict Which Day the Model Has the Smallest Error Given the Features

Using different models, we tried knn, logistic regression, XGBoost, and an artificial neural network. 

Due to the way kaggle scores, final Predictions could not be a weighted average of the results. We selected which was most likely to be the final.

# Conclusions

The models ensamble was able to outperform each of the individual. In practice, it is likely that we are too use these methods to forecast a months sales. this would be aggrigated.

# references
