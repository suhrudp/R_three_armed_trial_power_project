---
title: "POWER & SAP"
author: "SP"
date: "2023-03-24"
output:
  html_document:
    df_print: paged
  word_document:
    fig_width: 10
    fig_height: 6
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# This is a project that I worked on at the Institute of Infectious Diseases, Pune. The objective of the study was to assess the trends
# in bodyweight after switching from drug A to drug B/drug b (lower dose of drug B)/continue on drug A. Since the study involved randomizing
# patients to these three arms, calculating sample size to enable comparisons between three groups was needed. The `ThreeArmedTrials` package
# is made for this explicit purpose. Please see the R code below to get a rough idea.

## POWER & SAMPLE SIZE

```{r include=FALSE}
# This will load the `ThreeArmedTrials` package
library(ThreeArmedTrials)
```

### OPTIMAL SAMPLE SIZE ALLOCATION CALCULATION

```{r}
# Input effect sizes for drug B (so called "experiment"), drug b (so called "reference"), and drug A arms (so called "placebo"); set a margin
# (delta), and choose what type of distribution and link function you want; store the optimal allocation it in an object for easier retrieval
# Here, these effect sizes (40%, 20%, and 5% probabilities of gaining clinically significant bodyweight >=5% have been agreed upon by an 
# expert consensus, since this is a novel clinical trial and there is no high level evidence related to this hypothesis
w <- ThreeArmedTrials::opt_alloc_RET(experiment = 0.4, 
                                     reference = 0.2, 
                                     placebo = 0.05,
                                     Delta = 0.7,
                                     distribution = "binary", 
                                     h = function(x){-log(x/(1-x))})
print(w)
```

# The optimal sample size allocation for a Wald-type test for a three-armed superiority trial, where the probability rate of patients on drug B
# who will lose ≥5% weight is estimated to be 40%, for drug b is estimated to be 20%, and for the reference group continuing on drug A is
# estimated to be 5%, with a superiority margin of a log odds 0.7 (odds ratio of 2) and a binary distribution following a logit link function,
# is estimated to be 39.5%, 33.9%, and 26.6% approximately for the drug B, drug B, and drug A group respectively.

### SAMPLE SIZE AND POWER RELATED CALCULATIONS

```{r}
# With optimal allocation as calculated in the previous cell
ThreeArmedTrials::power_RET(experiment = 0.4, 
                            reference = 0.2, 
                            placebo = 0.05,
                            sig_level = 0.05, 
                            power = 0.8,
                            Delta = 0.7, 
                            allocation = w, 
                            distribution = "binary", 
                            h = function(x){-log(x/(1-x))}, 
                            h_inv = function(x){exp(-x)/(1+exp(-x))},
                            var_estimation = "RML")
```

# The sample size for a Wald-type test for superiority of transitioning to drug B versus drug b with respect to maintenance on drug A assuming
# a probability rate for outcomes of 40% in the drug B group, 20% in the drug b group, and 5% in the drug A group, an alpha error of 5%, power
# at 80%, a superiority margin log odds of 0.7 (odds ratio of 2) is calculated to be 29, 25, and 19 in the drug B, drug b, and drug A arms
# respectively.

```{r}
# With 1:1:1 allocation (not the optimal allocation)
ThreeArmedTrials::power_RET(experiment = 0.4, 
                            reference = 0.2, 
                            placebo = 0.05,
                            sig_level = 0.05, 
                            power = 0.8,
                            Delta = 0.7, 
                            allocation = c(1, 1, 1)/3, 
                            distribution = "binary", 
                            h = function(x){-log(x/(1-x))}, 
                            h_inv = function(x){exp(-x)/(1+exp(-x))},
                            var_estimation = "RML")
```

# The goal is to see whether transitioning to drug B is clearly superior to transitioning to drug b from drug A with respect to maintaining on
# drug A in losing clinically significant bodyweight (≥5%) at 48 weeks in patients transitioning from drug A Following this, the primary
# hypothesis that arises is:
# Whether transitioning to drug B from drug A is superior to transitioning to drug b with respect to maintenance on drug A in losing clinically
# significant bodyweight (≥5%) at 48 weeks.

# Secondary hypotheses include:
# 1.  Whether transitioning to drug B from drug A is superior to maintenance on drug A in losing clinically significant bodyweight (≥5%) at 48
# weeks.
# 2.  Whether transitioning to drug b from drug A is superior to maintenance on drug A in losing clinically significant bodyweight (≥5%) at 48
# weeks.
# 3.  Whether transitioning to drug B from drug A is superior to transitioning to drug b from drug A with respect to maintenance on drug A in
# losing clinically significant bodyweight (≥5%) at 48 weeks after stratifying for type 2 diabetes mellitus.

# Based on clinical judgement, we anticipate that there is 40% probability that patients on drug B will lose clinically significant bodyweight
# (≥5%) after transitioning from drug A, 20% probability that patients on drug b will lose clinically significant bodyweight (≥5%) after
# transitioning from drug A , and 5% probability that patients maintained on drug A will lose clinically significant bodyweight (≥5%).

# Sample size is calculated for a superiority three-arm trial with binary endpoints using the logit link function for a Wald-type test using
# the restricted variance estimation (RML). The allocation ratio is 1:1:1. We decided a log odds superiority margin (delta) of 0.7
# (corresponding to an odds ratio of 2) to be clinically significant to investigate the superiority of drug B over drug b The required sample
# size for achieving 80% power at a significance level of 5% is 27 patients in each group (N = 81). Assuming a dropout rate of approximately
# 20% over a 48-week period in an urban population, we plan to recruit 35 patients in each group (N = 105).

### TESTING THE RETENTION OF EFFECT HYPOTHESIS

```{r include=FALSE}
# Please note that the datafile contained contains fictional simulated data and NOT the real data of patients
df1 <- read.csv("/your/data/for/testing/the/retention/of/effect/hypothesis/RoE data.csv")
# Define variable types
df1$Experimental <- as.numeric(df1$Outcome)
df1$Group <- as.factor(df1$Group)
```

```{r include=FALSE}
# To change the reference group as needed
df1$Group <- relevel(df1$Group, ref = "Drug b")
```

```{r include=FALSE}
# To change the reference group as needed
df1$Group <- relevel(df1$Group, ref = "Drug A")
```

```{r}
# Test the retention of effect hypothesis
ThreeArmedTrials::test_RET(xExp = df1$Outcome[df1$Group == "Drug B"],
                           xRef = df1$Outcome[df1$Group == "Drug b"],
                           xPla = df1$Outcome[df1$Group == "Drug A"], 
                           Delta = 0.7, 
                           var_estimation = "RML",
                           distribution = "binary",
                           h = function(x){-log(x/(1-x))},
                           h_inv = function(x){exp(-x)/(1+exp(-x))})
```

```{r}
# Perform a manual binary logistic regression
fit <- glm(formula = Outcome ~ Group, family = binomial, data = df1)
summary(fit)
coef(fit)
confint(fit)
```

# We tested the retention of effect hypothesis on a simulated dataset with 1:1:1 allocation and 35 participants in each group. Fourteen
# patients on drug B, seven patients on drug b, and two patients on drug A lost clinically significant bodyweight (≥5%). A Wald-type test
# yielded a statistically significant p-value (p = 2.494e-03) between the drug B and drug b groups with respect to drug A indicating that there
# is a significant difference between the groups.

```{r include=FALSE}
# Plot a figure to illustrate various scenarios regarding confidence interval crossing of the null point and margins well ahead in the 
# analysis plan itself before study commencement
df2 <- read.csv("your/hypothetical/data/for/the/point/estimate/and/confidence/limits/CI figure.csv")
```

```{r include=FALSE}
library(ggplot2)
```

```{r}
# Set the defined margin (0.7) to illustrate various possible scenarios
ggplot2::ggplot(data = df2) + 
         geom_errorbar(aes(xmin = LCL, xmax = UCL, y = ID)) + 
         geom_vline(xintercept = c(0, 0.7), lty = c(1, 4)) + 
         scale_x_continuous(breaks = seq(-0.2, 3.2, 0.2)) +
         theme_minimal() +
         xlab("Log Odds")
```

# In the figure, each point estimate with its CI can be interpreted as follows:
# 1.  Shows the lower confidence limit for the log odds which is far away from the superiority margin (delta) at 0.7 - superiority shown.
# 2.  Shows the lower confidence limit for the log odds which is close, but not crossing the superiority margin (delta) at 0.7 - superiority shown.
# 3.  Shows the confidence interval crossing the superiority margin (delta) at 0.7 - superiority not shown.
# 4.  Shows the confidence interval with the upper confidence limit lower than the superiority margin (delta) at 0.7 - superiority not shown.
# 5.  Shows the confidence interval with the upper confidence limit lower than the superiority margin (delta) at 0.7 - superiority not shown.
# 6.  Shows the confidence interval with the upper confidence limit lower than the superiority margin (delta) at 0.7 - superiority not shown.

## STATISTICAL ANALYSIS PLAN

# The intention-to-treat protocol will be followed to maintain randomization and sample size. The primary endpoint will a comparison of the
# drug B arm to the drug b arm with respect to the drug A arm in losing clinically significant bodyweight (≥5%). Since the goal is to see
# whether drug B is superior to drug b in losing clinically significant bodyweight (≥5%) at 48 weeks, the primary hypothesis will be whether
# transitioning to drug B from drug A is superior to transitioning to drug b from drug A with respect to maintenance on drug A We anticipate
# the drug B arm to show the highest reduction in bodyweight, the drug A arm to show the least reduction in bodyweight, and the drug b ar to
# show an intermediate reduction in bodyweight at 48 weeks.

# For the primary outcome, a logistic regression model will be used to compare the odds of achieving clinically significant bodyweight loss
# (≥5%) with the drug A arm serving as the reference class. The model will be adjusted to the following confounding variables: presence of
# diabetes mellitus, age, sex, duration on drug A, baseline BMI, and baseline CD4 levels. Linear mixed effects (LME) models with each
# participant as a random intercept will be used to fit and predict CD4 counts, weight, BMI, wait-hip ratio, blood sugar levels, HbA1c levels,
# lipid parameters, and estimated GFR over time. Logistic regression models adjusted for confounders will be used to estimate the odds of
# events with their risk factors. Kaplan-Meier analyses will be performed to estimate median times to events. The log-rank test will be used to
# compare Kaplan-Meier estimates. Cox regression models adjusted for confounders will be used to get hazard estimates for the occurrence of
# events over time. The proportional hazards assumption will be tested using Schoenfeld residuals. Chi-square or Fisher's exact tests will be
# used to compare categorical variables as appropriate. The Cochran-Mantel-Haenszel test will be used for simple stratified analysis. Student's
# t-tests or analysis of variance techniques (ANOVA) will be used to compare continuous variables for two or more groups respectively. Patients
# who had achieved events of interest at baseline will be censored from the concerned analyses.

# Subgroup analyses will be performed to assess the robustness and validity of the results, and whether associations are stronger or weaker in
# different subgroups. Similar statistical methods will be used in subgroup analyses to those used to assess primary and secondary outcomes.
# Subgroups will include patients with baseline BMI ≥25 kg/m^2 and those with <25 kg/m^2, males and females, family history of obesity and
# those without, CyP2B polymorphisms and those without, and those with baseline CD4 ≤350 cells/cumm and those >350 cells/cumm.

# For the two co-primary outcomes, p-values less than the alpha significance level of 0.025 (0.05/2) will be considered to be statistically
# significant. For the rest of the secondary outcomes, p-values less than 0.001 (0.05/50) will be considered to be statistically significant;
# exact p-values, effect sizes and point estimates with their 95% confidence intervals will be reported.
