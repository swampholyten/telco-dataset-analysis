Applied Statistics
Example exercises in exam format

EXERCISE: Heart ejection fraction prediction
The file Heart_ejection_fraction.csv contains clinical information on patients with heart failure. The response variable is
ejection_fraction, which measures the percentage of blood pumped out of the left ventricle at each heartbeat.

Ejection fraction is an important indicator of cardiac function: lower values generally indicate poorer pumping ability and
more severe impairment. In this exercise, the goal is to build and compare linear regression models for predicting
ejection fraction from the available clinical variables.

Because several predictors may be correlated or only weakly informative, you will use penalized regression methods,
especially Lasso regression, both to improve prediction and to perform embedded feature selection.

Use the same type of workflow seen in the lab: preprocessing with ColumnTransformer, scaling of quantitative
predictors, one-hot encoding of categorical predictors, pipelines, cross-validation for alpha, nested cross-validation,
and careful separation between model selection and final evaluation.

Question 1. Exploration and preprocessing
Inspect the variables and decide which variables should be treated as quantitative and which should be treated as
categorical.

Your answer must include: at least two concrete observations from the dataset; a comment on the scale of the
quantitative variables; a comment on correlated predictors; the preprocessing steps needed before fitting penalized
linear models.

Question 2. Compare OLS, Ridge, and Lasso with fixed penalties
Use a single train/test split. Fit three initial models: ordinary least squares, Ridge regression with alpha = 10, and Lasso
regression with alpha = 1.

Your answer should include: test-set R2, RMSE, and MAE; a coefficient comparison; and a short explanation of how
Ridge and Lasso behave differently.

Question 3. Tune alpha by cross-validation
Use cross-validation on the training set to choose alpha for Ridge and Lasso over a logarithmic grid.

Your answer should include: the alpha grid; the selected alpha values; a plot or table of cross-validated performance;
final test-set performance after tuning; and an explanation of what data are used in the inner folds versus the held-out
test set.

Question 4. Interpret the tuned Lasso model as feature selection
Inspect the coefficients of the tuned Lasso model.

Your answer should include: the variables retained by Lasso; the variables shrunk to zero; at least three coefficient
interpretations; and one caveat about interpreting selected variables when predictors are correlated.

Question 5. Nested CV, final refit, and post-selection linear model
Use nested cross-validation to estimate performance when alpha tuning is part of the modelling procedure. Then refit
Lasso on all available data to select a final set of variables.

Finally, fit an ordinary linear regression model on the full dataset using only the variables selected by the final Lasso
model. Comment on coefficient estimates, signs, p-values, and limitations of post-selection inference.

Before you start
Try to solve the exercise before reading the solution. The solution is one possible strong answer; other solutions can be
correct if the reasoning is statistically coherent and the outputs support the comments.

Reminder. Ridge and Lasso are penalized linear models. Scaling is required because the penalty is applied to coefficient sizes.
Categorical variables should be encoded inside the pipeline. Scaling and encoding should be learned only from the training data or
from the training folds within cross-validation.

The exercise uses several related, but different, data-splitting ideas. In Question 2, the split is a simple train/test split. In
Question 3, the training set is split internally by GridSearchCV to select alpha, while the test set remains untouched. In
Question 5, nested CV repeatedly creates outer train/test folds and, inside each outer training fold, creates inner folds
for alpha selection. After this evaluation step, a final model can be refit on all available data for reporting and
interpretation.

Solutions: Exercise 1

Question 1 - Exploration and preprocessing
A strong answer should identify seven quantitative predictors: age, creatinine_phosphokinase, platelets,
serum_creatinine, serum_sodium, bmi, and time. The categorical predictors are anaemia, diabetes,
high_blood_pressure, sex, and smoking.

The quantitative predictors are on very different scales. For example, platelets are measured in hundreds of thousands,
creatinine_phosphokinase can take values in the thousands, while serum_creatinine and bmi are on much smaller
scales. Since Ridge and Lasso penalize coefficient size, the penalty would be scale-dependent if the variables were not
standardized. Therefore, quantitative predictors should be standardized before fitting penalized models.

The categorical variables should be one-hot encoded, using one level as the reference category. Importantly, both
scaling and one-hot encoding should be inside the Pipeline. This ensures that preprocessing is fitted only on the training
data in a train/test split, and only on the training folds inside cross-validation.

Table 1. Descriptive summary for quantitative variables.

Variable
age
creatinine_phosphokinase
platelets
serum_creatinine
serum_sodium
bmi
time
ejection_fraction

mean
61.32
378.66
254070.61
1.300
136.20
28.23
170.13
34.87

std
11.85
372.83
53737.07
0.330
2.200
4.160
65.13
6.370

min
40.00
35.00
85000.00
0.550
129.50
18.00
28.00
17.00

max
93.00
2236.00
394501.00
2.110
141.70
39.30
290.00
50.00

Table 2. Frequency table for categorical variables.

Variable
anaemia
anaemia
diabetes
diabetes
high_blood_pressure
high_blood_pressure
sex
sex
smoking
smoking

Level
No
Yes
No
Yes
No
Yes
Female
Male
No
Yes

n
169
71
110
130
115
125
112
128
158
82

percent
70.40
29.60
45.80
54.20
47.90
52.10
46.70
53.30
65.80
34.20

Figure 1. Correlations among quantitative variables. Correlation does not prevent fitting Lasso, but it affects coefficient interpretation and
variable selection.

Variable 1
age

Variable 2
serum_creatinine

Correlation
0.510

Table 3. Predictor pairs with moderate absolute correlation.

Question 2 - Compare OLS, Ridge, and Lasso with fixed penalties
This part uses one train/test split. The training set is used to fit the preprocessing steps and the three models. The test
set is used only after fitting, to compare predictive performance. This is the simplest validation structure in the exercise.

The fixed values alpha = 10 for Ridge and alpha = 1 for Lasso are not tuned. They are used to illustrate how shrinkage
works. OLS has no penalty. Ridge adds an L2 penalty, which shrinks coefficients toward zero but usually keeps all
predictors. Lasso adds an L1 penalty, which can set some coefficients exactly to zero and therefore acts as an
embedded feature-selection method.

Table 4. Test-set metrics for the fixed-penalty comparison.

Model
OLS
Ridge alpha=10
Lasso alpha=1

Test R^2
0.417
0.403
0.223

Test RMSE
4.932
4.990
5.694

Table 5. Coefficient comparison for the fixed-penalty models.

Feature
Intercept
num__age
num__creatinine_phosphokinase
num__platelets
num__serum_creatinine

OLS
37.17
0.362
-0.330
0.434
-2.400

Ridge alpha=10
36.67
0.149
-0.289
0.413
-2.361

Test MAE
4.099
4.188
4.675

Lasso alpha=1
34.61
-0.000
-0.000
0.000
-2.407

num__serum_sodium
num__bmi
num__time
cat__anaemia_Yes
cat__diabetes_Yes
cat__high_blood_pressure_Yes
cat__sex_Male
cat__smoking_Yes

0.870
-2.149
0.309
-0.609
-2.119
-1.206
-0.322
-1.115

0.879
-2.076
0.293
-0.511
-1.674
-0.981
-0.264
-0.901

0.152
-1.414
0.000
-0.000
-0.000
-0.000
-0.000
-0.000

A good interpretation should not focus only on the metric with the largest value. The relevant point is that the three
models are fitted on the same data split and use the same preprocessing. Differences are therefore attributable to the
modelling choice and the penalty, not to different preprocessing or different samples.

Question 3 - Tune alpha by cross-validation
This part changes the splitting structure. We still begin with the same train/test split, but alpha is selected only inside the
training set. GridSearchCV splits the training data into internal folds. For each candidate alpha, the pipeline is refit inside
the CV loop: the scaler, encoder, and model are all fitted on the training folds and evaluated on the validation fold. The
external test set is not used to choose alpha.

The alpha grid is np.logspace(-2, 2, 15). The selected Ridge alpha is 26.8270 and the selected Lasso alpha is 0.1389.

Figure 2. Mean cross-validated R2 across alpha values. Dashed vertical lines indicate the selected alpha values.

Table 6. Test-set metrics after tuning alpha by cross-validation.

Model
OLS
Ridge tuned
Lasso tuned

Test R^2
0.417
0.388
0.354

Test RMSE
4.932
5.053
5.191

Test MAE
4.099
4.261
4.309

Only after alpha has been chosen do we evaluate the tuned Ridge and tuned Lasso models on the held-out test set. This
gives an estimate of performance for the selected models on data not used either for fitting the final training model or for
choosing alpha.

Question 4 - Interpret the tuned Lasso model as feature selection

Table 7. Non-zero coefficients retained by the tuned Lasso model.

Feature
num__serum_creatinine
num__bmi
cat__diabetes_Yes
num__serum_sodium
cat__smoking_Yes
cat__high_blood_pressure_Yes
num__platelets
num__time
num__creatinine_phosphokinase

Lasso tuned
-2.545
-2.079
-1.330
0.771
-0.443
-0.425
0.250
0.196
-0.127

Figure 3. Non-zero tuned-Lasso coefficients. Numeric variables have been standardized; categorical coefficients are differences relative to the
reference level after encoding.

The tuned Lasso retains 9 predictors and shrinks 3 predictors to zero. A student should explicitly discuss this as feature
selection, not just report the prediction metrics.

For standardized quantitative variables, a coefficient is the expected change in predicted ejection_fraction for a one-
standard-deviation increase in that predictor, holding the other predictors in the fitted penalized model fixed. For
example, a negative coefficient for serum_creatinine means that higher serum_creatinine is associated with lower
predicted ejection_fraction. A positive coefficient for serum_sodium means that higher serum_sodium is associated with
higher predicted ejection_fraction. A negative coefficient for bmi or age means that larger values are associated with
lower predicted ejection_fraction in this fitted model.

For categorical variables, the coefficient is interpreted relative to the reference level. For example, diabetes_Yes is
interpreted as the difference between patients with diabetes and the reference group without diabetes, holding the other
fitted predictors fixed.

Variables shrunk to zero by the tuned Lasso are: num__age, cat__anaemia_Yes, cat__sex_Male.

A zero coefficient does not prove that the variable is irrelevant. With correlated predictors, Lasso may keep one
representative predictor and remove another that carries overlapping information. The selected set can also
change if the sample, split, or alpha grid changes.

Figure 4. Observed versus predicted ejection_fraction for the tuned Lasso model on the test set.

Question 5 - Nested CV, final refit, and post-selection linear model
Nested cross-validation changes the evaluation target. Instead of evaluating one model selected on one training set, it
evaluates the whole procedure: choose alpha by inner CV, fit the selected model on the outer-training fold, and evaluate
it on the outer-test fold. This is more honest when we want to estimate the performance of a tuning procedure.

Table 8. Nested cross-validation summary for Ridge and Lasso.

Model
Ridge
Lasso

Nested R^2 mean
0.462
0.439

Nested R^2 SD
0.027
0.046

Nested RMSE mean
4.649
4.750

Nested MAE mean
3.777
3.814

Ridge selected alphas across outer folds: 13.9, 13.9, 26.8.

Lasso selected alphas across outer folds: 0.268, 0.139, 0.518.

The variation in selected alpha across outer folds is informative: the best penalty is data-dependent. This is why nested
CV is used for performance assessment, while the final deployable model is obtained only after this assessment step.

After nested CV, we refit/tune Lasso on the full dataset to obtain one final selected set of predictors. The selected alpha
in this final all-data fit is 0.2683.

Table 9. Non-zero coefficients after final Lasso retuning on all data.

Feature
num__bmi
num__serum_creatinine
cat__diabetes_Yes
num__serum_sodium
cat__smoking_Yes
cat__high_blood_pressure_Yes
num__platelets
num__creatinine_phosphokinase

Coefficient
-2.108
-2.097
-1.388
0.838
-0.485
-0.250
0.157
-0.066

For the final statistical interpretation requested in the exercise, we now fit an ordinary linear regression model on the full
dataset using only the variables selected by the final Lasso model. This model is not used to re-select variables; it is used
to inspect signs, standard errors, t-statistics, p-values, and confidence intervals for the selected variables.

Table 10. Overall fit summary for the final post-selection OLS model.

n
240.00

R^2
0.500

Adj. R^2
0.483

F p-value
0.000

AIC
1420.52

BIC
1451.85

Table 11. Final OLS coefficients using variables selected by Lasso.

Term
const
bmi
serum_creatinine
diabetes_Yes
serum_sodium
smoking_Yes
high_blood_pressure_Yes
platelets
creatinine_phosphokinase

Estimate
-6.032
-0.534
-5.244
-2.482
0.467
-1.925
-1.361
0.000
-0.0010

Std. Error
19.76
0.076
1.188
0.762
0.141
0.630
0.688
0.000
0.0008

t
-0.305
-7.031
-4.414
-3.256
3.309
-3.054
-1.978
1.654
-1.272

p-value
0.760
0.000
0.000
0.0013
0.0011
0.0025
0.049
0.100
0.205

CI 2.5%
-44.96
-0.683
-7.585
-3.984
0.189
-3.168
-2.717
-0.000
-0.0026

CI 97.5%
32.89
-0.384
-2.903
-0.980
0.744
-0.683
-0.0051
0.000
0.0006

Figure 5. Coefficient estimates from the final OLS refit using variables selected by the final Lasso model.

At the conventional 5% level, the statistically significant selected predictors in this post-selection OLS refit are: bmi,
serum_creatinine, diabetes_Yes, serum_sodium, smoking_Yes, high_blood_pressure_Yes.

Selected predictors that are not significant at the 5% level in this refit are: platelets, creatinine_phosphokinase.

Important limitation. These p-values are ordinary OLS p-values computed after the variables have already been selected by Lasso.
They are useful for teaching how to read a final regression table, but they should not be presented as fully valid post-selection
inference without additional methods. The selection step makes classical p-values too optimistic in general.

A good final answer should therefore separate three claims: predictive performance, sparse feature selection, and
statistical significance in the post-selection linear model. Lasso can be useful for prediction and simplification, but
selected variables should still be interpreted with caution.


