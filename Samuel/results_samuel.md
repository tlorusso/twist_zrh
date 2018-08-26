# Exploratory data analysis  
* The *distribution of the difference* in seconds has many extreme values and also seems to be skewed. As expected the difference in seconds is more skewed for starting flights than for landing flights.  
* Looking at the distribution of the difference in seconds for the different *months* over the year, one can clearly see that there are some seasonal patterns. The summer and winter holiday seasons are associated with higher difference in seconds.
* Similar periodic patterns are visibile when looking at the the distribution of the difference in seconds at the different *hours* of the day. More delays occur in the morning compared to lunchtime, the afternoon, and in the evening.
* Visually there is no difference in the distribution of the difference in seconds visible *comparing Schengen to Non-Schengen* flights.
* Looking at the difference in seconds distributions conditioned on the different *airlines*, it's clearly visible that some of them have more and longer delays than others. Thinking about possible explanations for the more frequent delays of different airlines we hypothesize that low-cost airlines (e.g. Air Berlin) try to minimize the time on the ground because of monetary reasons. Also we think that higher security standards could explain the more frequent delays of other airlines (e.g. El Al Israel).
* Also visually visible are delay differences between the *different airplane* types. We hypothesize that the airlines have different airplane fleets and therefore some airplane types are not uniformly represented over all airlines. That's why we think that the delays associated with certain airlines propogate to the airplane types. 
* When looking at the *correlation between quantitative covariates*, it's visible that some of them are strongly correlated. A possibility to deal with this would be to use dimension reduction techniques such as principal component analysis. Unfortunately, we checked this only when we didn't have enough time anymore to that.

## Modeling
* When fitting a multiple linear regression model with some of the quantitative variables and looking at the model diagnostics, we can see that the residual distribution has extremely long tails and is clearly not Gaussian. Therefore, our model assumptions are violated. This is probably due to the many extreme observations which we are not able to capture with our model. At a later point we tried to exclude some of the extreme values and fit a linear model on the remaining data (see further below).
* I also used an exhaustive search algorithm the select the model with the quantitative covariates that reduce the BIC criterion the most. This model included almost all of the quantitative covariates and $R^2$ didn't improve much (was still very low), also the diagnostics indicate a very bad model fit.
* We then decided to use a different approach and categorize the difference in seconds variable as delayed when the difference was larger than 30 minutes, and as not delayed otherwise. Then we used a logistic regression model to model the probability of a delay. We achieved a training-missclassification rate of around 10 percent.
* To capture time trends, we introduced the month and hour covariates to the models which could improve the model fit in the linear and also in the logistic model. The missclassification rate didn't change in the latter, but difference in the residual deviance was significantly different when testing with a likelhood ratio test.
* I then tried to evaluate the logistic regression model with 10-fold crossvalidation which resulted in a similar missclassification rate of around 10 percent. 
* Since we only used additive effects and no interactions in the model, we are able to look at the model predicitions of one covariate when keeping the other variables fixed (here at their median value, respectively their most common category).
    - Higher flight distance is associated with lower delay probability
    - Higher windspeends are associated with higher delay probability
    - More lightnings far away are associated with higher delay probability
    - Higher airpressure is associated with lower delay probability
    - There is are seasonal patterns. The closer to the holidays the higher the delay probability
    - Flights in the morning are associated with less delay probability than 
    - More lightnings nearby are associated with lower delay probability
    - More relative humidity is associated with higher delay probability. This is counterintuitive and we don't really have an explanation.
* We tried to fit a mixed logistic regression model with random intercepts for airline and airplane types, but the optimization ran into numerical issues
* We also fitted a Bayesian logistic regression model with lasso regularization priors. THe coefficients mean estimates turned out to be very similar to the frequentistic logistic regression model. 

## What could be done in the future
* Try to rewrite the code less messy
* Use dimension reduction techniques like PCA to have less covariates and then regress the outcome on them
* Not categorize the delay time and try to transform it / use more robust methods
* Use random effects in the Bayesian model for airlines and airplanes
* Analyze the delays of landing flights by also getting the weather data of the destination from where they came from
* Use more complex models (boosting, random forests, neural networks) to improve predicitive performance (at the cost of interpretability)
