Applied Statistics
Example exercises in exam format

EXERCISE 1: Student profiles
The file student_profiles.csv contains measurements on 150 students, describing study habits, lifestyle, and
academic characteristics.

Your goal is to investigate whether the data support the presence of meaningful student profiles.

You are not asked to follow one fixed pipeline. Instead, you should motivate your analytical choices and
document your reasoning clearly.

Question 1. Initial exploration and preprocessing choice
Inspect the variables and discuss what preprocessing steps may be appropriate before applying
dimensionality reduction or clustering.

Your answer must include:

the preprocessing decision(s) you take,

•
•  a short justification for each decision.

Question 2. Is PCA useful here?
Apply PCA and discuss whether it is useful in this problem.

Your answer should include:

•  evidence based on explained variance and/or scree plot,
•
•  a brief discussion of whether PCA should be used only for visualization, also for clustering, or not

interpretation of at least the first two principal components,

retained for the final clustering workflow.

Question 3. Compare two reasonable clustering workflows
Construct and compare at least two defensible clustering analyses. For example, you may compare:

Your answer should include:

clustering on standardized original variables versus clustering on PCA scores,
two different linkage criteria,
two different values of k,

•
•
•
•  or another reasonable contrast.

For each workflow, report:

the main analytical choices,

•
•  one numerical criterion,
•  one interpretability-based comment.

Then state which workflow you prefer at this stage and why.

Question 4. Final clustering solution and interpretation
Choose one final clustering solution.

Describe the resulting clusters using the original variables, and explain why the groups are meaningful or
not meaningful.

Question 5. Reflect on uncertainty and limitations
Discuss one limitation or source of uncertainty in your final analysis.

Examples could involve:

sensitivity to scaling,
sensitivity to outliers,

•
•
•  ambiguous number of clusters,
•  weak interpretability of one component or one group,
•

tension between numerical indices and substantive interpretation.

EXERCISE 2: Museum Experience
The file museum_experience.csv contains daily measurements from an experimental exhibition. Each row
corresponds to one exhibition-day and reports characteristics of the room configuration, visitor flow, and
contextual factors.

The response variable is avg_visit_minutes, the average time visitors spent inside the exhibition on that
day.

Your goal is to investigate how the recorded variables are associated with visit duration, and whether a
multiple linear regression model provides a useful and reliable description of these relationships.

You are not asked to follow one fixed pipeline. Instead, you should motivate your analytical choices and
document your reasoning clearly.

Question 1. Initial exploration and baseline model choice
Inspect the variables and propose a reasonable baseline multiple linear regression model.

Your answer must include:

•  a discussion of whether some predictors appear strongly related to each other,
•
the predictors you include in the baseline model,
•  a short justification for your initial modeling choice.

Question 2. Fit the baseline model and check whether it seems trustworthy
Fit your baseline multiple linear regression model and investigate whether there are warning signs that may
affect the analysis.

Your answer should include:

the fitted model,

•
•  appropriate checks of model adequacy,
•  a brief discussion of whether there are unusual observations, problematic residual patterns, or other

issues that deserve attention before interpreting the coefficients.

Question 3. Investigate unusual observations and decide how to proceed
Study more carefully whether there are outliers, high-leverage points, or influential observations.

Your answer should include:

identification of any such cases,

•
•  a short explanation of why they may matter,
•  a decision on whether one or more observations should be removed from the analysis.

If you decide to remove observations, justify the choice clearly.

Question 4. Refit the model and interpret it only if reasonable
After your previous checks, fit the model you consider most appropriate and discuss the results.

Your answer should include:

the final fitted model,
interpretation of at least three coefficients,

•
•
•  at least one interpretation written explicitly as a partial effect, that is, holding the other predictors

fixed,

•  a brief comment on whether the model now seems useful and interpretable.

Question 5. Extend the model with the categorical variable
Include the categorical variable theme_type in the regression model and discuss how the interpretation
changes.

Your answer should include:

•  how the categorical predictor is represented in the model,
•  what the reference category is,
•
interpretation of at least one coefficient associated with theme_type,
•  a brief comment on whether including this variable improves the analysis.

Question 6. Reflect on linearity, uncertainty, and limitations
Discuss whether the linear specification appears fully adequate and mention one limitation or source of
uncertainty in your final analysis.

Examples could involve:

•  possible nonlinearity for one predictor,
•
•
•  model assumptions that may not be fully satisfied.

correlated predictors,
tension between statistical significance and practical relevance,

Before you start
Try to solve each exercise before reading the solution.
The solutions are provided to help you compare your reasoning with one possible strong answer,
not to be memorized.

i.

What kind of answer is expected

Your answers should be short but complete.
You do not need to write long essays. Clear, specific, and well-justified comments are preferable to
vague or repetitive discussion.
Whenever relevant, your answer should:

•  explain the main analytical choices you made;
•
•

report the numerical results you are referring to;
include plots or tables when they help support your conclusions.

Formatting is not the main concern. Your tables and figures do not need to look polished. What
matters is that the relevant quantities are visible and easy to read. If you cite a number in the text,
that number should also be clearly shown in the output, for example in a table, a model summary,
or a figure.

ii.

More than one solution can be correct

These exercises are intentionally open. In many cases, there is not one single correct workflow or
one hidden correct answer. Different solutions can be acceptable if they are statistically coherent
and well explained.
In particular:

a different preprocessing choice may be acceptable if justified;

•
•  more than one clustering solution may be reasonable;
•  more than one regression refinement decision may be defensible;
•

a student can receive full or nearly full credit without reproducing the exact solution shown here,
provided the reasoning is sound.

iii.

Important note about exam length

Real exams won’t contain as many questions as in the material shown here.
In the actual exam, you may encounter:

•  only one dataset with 3 to 4 questions, or
•

two shorter datasets with only 1 to 2 questions each.

This document is deliberately more extensive than a real exam, because its purpose is to let you
practice the type of reasoning expected and to see several possible question styles in one place.

Solutions: Exercise 1

Question 1 - Initial exploration and preprocessing
A full-credit answer should notice that the variables live on very different scales. For example,
social_media_minutes and commute_minutes have much larger raw spread than sleep_hours or
coffee_per_day, so any Euclidean-distance-based method would otherwise be dominated by a few large-
scale variables.

A strong answer should also notice at least one of the following: (i) there are clearly correlated engagement
variables such as lecture_attendance, notes_pages_per_week, past_exam_average, and
engagement_index; (ii) a few observations appear unusual, especially on commute_minutes, screen_time,
and study_hours; (iii) early_classes_per_week is numeric but discrete, so a student may reasonably keep it
as a count variable while still noting that it is not continuous.

Table 1. Raw spread summary for all variables.

Variable

social_media_minutes

commute_minutes

notes_pages_per_week

lecture_attendance

engagement_index

study_hours

part_time_work_hours

past_exam_average

early_classes_per_week

screen_time

stress_score

exercise_hours

sleep_hours

coffee_per_day

std

57.84

21.46

13.39

13.1

7.96

5.66

4.93

2.07

1.56

1.4

1.34

1.01

0.66

0.58

min

20.0

2.0

15.66

38.14

10.0

5.76

0.0

19.14

0.0

2.33

1.77

0.0

5.36

0.75

max

337.98

105.0

78.8

100.0

49.44

35.0

26.85

30.0

6.0

10.8

8.49

5.65

8.61

3.27

Figure 1. Raw standard deviations by variable. The large spread differences justify standardization before PCA or hierarchical
clustering.

Figure 2. Correlation matrix. The engagement-related variables are partly redundant, which is one reason PCA is helpful here.

Preprocessing decision.

Standardize all variables before PCA and clustering. Keep early_classes_per_week in the analysis, but
explicitly note that it is a discrete count. Do not remove engagement_index automatically, although a
student may reasonably flag it as partly redundant and propose a sensitivity check without it.

In distance-based methods, variables with larger scales contribute more to the distance unless the
data are standardized. Standardization is not a ritual: it is useful when the units or spreads of the
variables differ enough that some variables would otherwise dominate the analysis.

Question 2 - Is PCA useful here?
PCA is useful in this dataset for two reasons. First, it summarizes a correlated block of engagement and
academic-performance variables. Second, it provides a low-dimensional representation for visual
comparison of clustering solutions. At the same time, PCA does not magically solve the problem, and
students will not be penalized for concluding that it is more useful for exploration than as the sole basis of
the final clustering decision.

PCA constructs new variables, called principal components, that are linear combinations of the
original variables. The first principal component captures the largest possible amount of variance,
the second captures the largest remaining variance subject to being orthogonal to the first, and so
on. In practice, PCA can be useful when several original variables contain overlapping information,
because it summarizes shared structure in a smaller number of dimensions.

A high explained variance does not automatically imply that PCA is the best basis for clustering. PCA
is optimized to summarize variance, not necessarily to recover cluster structure. This is why
clustering on PCA scores should be compared with clustering on the standardized original variables
rather than assumed to be superior.

Table 2. Explained variance of the first six principal components.

PC

PC1

PC2

PC3

PC4

PC5

PC6

Explained variance

Cumulative variance

0.417

0.1525

0.0782

0.0641

0.0531

0.0469

0.417

0.5694

0.6476

0.7117

0.7649

0.8118

Figure 3. Scree plot with cumulative explained variance. PC1 explains about 41.7% of the variance; the first two PCs explain about
56.9%.

Table 3. Most salient loadings for the first four PCs.

PC

PC1

PC1

PC1

PC1

PC1

PC1

PC2

PC2

PC2

PC2

PC2

PC2

PC3

PC3

PC3

PC3

PC3

Variable

lecture_attendance

engagement_index

past_exam_average

stress_score

notes_pages_per_week

study_hours

coffee_per_day

sleep_hours

part_time_work_hours

exercise_hours

commute_minutes

notes_pages_per_week

coffee_per_day

early_classes_per_week

social_media_minutes

commute_minutes

part_time_work_hours

Loading

0.348

0.338

0.324

-0.323

0.302

0.298

0.385

-0.381

0.372

-0.329

0.309

0.277

0.545

-0.447

0.424

-0.393

-0.279

PC3

PC4

PC4

PC4

PC4

PC4

PC4

sleep_hours

exercise_hours

screen_time

coffee_per_day

sleep_hours

stress_score

part_time_work_hours

-0.183

0.431

0.399

0.378

0.369

-0.34

0.293

Figure 4. Loadings heatmap for PC1-PC4.

Suggested interpretation.

PC1 is an academic engagement / academic strength axis. It loads positively on lecture_attendance,
engagement_index, past_exam_average, notes_pages_per_week, and study_hours, and negatively on
stress_score, screen_time, and social_media_minutes. High PC1 therefore corresponds to stronger
academic engagement and lower digital distraction/stress.

PC2 is a constraints / workload axis. It loads positively on coffee_per_day, part_time_work_hours,
commute_minutes, study_hours, and notes_pages_per_week, and negatively on sleep_hours and
exercise_hours. This can be interpreted as a trade-off between external workload and recovery.

Conclusion.

PCA is useful and should at least be used for exploration and visualization. A student can legitimately retain
PCA scores for clustering, or use PCA mainly to understand the structure and then compare clustering on
standardized original variables.

Question 3 - Compare candidate clustering workflows
Below is a compact comparison of several reasonable workflows. Note that the numerically best silhouette
score is not automatically the best substantive solution, because some average-linkage solutions isolate a
singleton outlier.

Space

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (2 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

PCA (3 PCs)

Standardized variables

Standardized variables

Standardized variables

Standardized variables

Standardized variables

Standardized variables

Table 4. Comparison of clustering workflows.

Linkage

average

average

average

complete

complete

complete

ward

ward

ward

average

average

average

complete

complete

complete

ward

ward

ward

average

average

average

complete

complete

complete

k

2

3

4

2

3

4

2

3

4

2

3

4

2

3

4

2

3

4

2

3

4

2

3

4

Silhouette

Cluster sizes

0.414

0.361

0.344

0.317

0.29

0.258

0.377

0.323

0.316

0.371

0.3

0.227

0.305

0.171

0.199

0.33

0.234

0.246

0.322

0.251

0.132

0.219

0.073

0.1

149, 1

82, 1, 67

67, 12, 70, 1

133, 17

71, 17, 62

63, 17, 62, 8

83, 67

67, 48, 35

48, 40, 35, 27

149, 1

83, 1, 66

66, 10, 73, 1

115, 35

92, 35, 23

35, 76, 23, 16

93, 57

60, 57, 33

57, 31, 33, 29

149, 1

148, 1, 1

146, 2, 1, 1

137, 13

95, 13, 42

42, 13, 65, 30

Standardized variables

Standardized variables

Standardized variables

ward

ward

ward

2

3

4

0.202

0.118

0.112

102, 48

53, 48, 49

49, 48, 36, 17

Figure 5. Silhouette scores across candidate workflows. (note: this plot – or exploring this many alternative configurations - is not
mandatory for the exam solution, it’s just provided to give students a benchmark of several alternatives they might decide to test)

Figure 6. PCA-space clustering under Ward linkage for k=2 (left) and k=3 (right).

Figure 7. Average linkage on the first two PCs with k=2. The high silhouette is misleading because the method isolates a singleton
(149 vs 1).

Figure 8. Ward dendrogram on the first two PCs.

The solution PCA (2 PCs) + average linkage + k=2 has the highest silhouette, but it should not be preferred
because it produces a 149 vs 1 split. This is a classic example of why one must inspect cluster sizes and not
trust one index blindly.

A stronger choice is PCA (2 PCs) + Ward linkage + k=2. It gives a balanced split (83 vs 67), a good silhouette,
and interpretable profiles. Ward with k=3 is also acceptable, especially if a student argues that the larger-
engagement group can be meaningfully split into a very strong cluster and a moderately strong cluster.

The silhouette score compares, for each observation, how close it is to its own cluster relative to the
nearest alternative cluster. Larger values suggest better separation, but the index is not sufficient on
its own. In particular, a solution can obtain a good silhouette while being substantively unhelpful, for
example if one cluster is just a singleton outlier.

Question 4 - Final solution and cluster interpretation
Recommended final solution: standardize the data, inspect PCA, and retain Ward clustering on the first two
PCs with k=2.

Table 5. Cluster means for the recommended final solution: PCA (2 PCs) + Ward, k=2.

Clu
ste
r

study
_hour
s

0.0  22.5

sleep
_hou
rs

6.95

1.0  14.72  6.67

60.4

lecture_a
ttendanc
e

notes_pag
es_per_we
ek

80.53

52.4

34.45

scree
n_tim
e

5.08

6.35

social_me
dia_minut
es

coffee_
per_da
y

135.0

196.72

2.11

2.07

stress
_scor
e

5.07

6.48

exercis
e_hour
s

commut
e_minut
es

part_time
_work_ho
urs

past_exa
m_avera
ge

engagem
ent_inde
x

early_class
es_per_we
ek

2.66

2.1

26.33

36.73

9.41

11.05

25.64

22.85

32.55

21.0

1.61

2.37

Figure 9. Standardized mean profiles for the final two-cluster solution.

Interpretation of Cluster 0.  Cluster 0 contains the more academically engaged students. Relative to Cluster
1, they study more, attend more, produce more notes, have higher past_exam_average, and a much higher
engagement_index. They also report lower stress, shorter commute, less social-media use, and more
exercise.

Interpretation of Cluster 1. Cluster 1 contains students with lower academic engagement and somewhat
greater daily constraints. They study less, attend less, have lower past_exam_average, longer commutes,
more social-media use, higher stress, and lower exercise.

A full-credit answer should tell a coherent story like the one above. It should not simply state that one
cluster has larger means than another. The student should explain what the pattern means substantively.

Clustering is exploratory and does not produce “true” classes guaranteed to exist in nature. A good
interpretation therefore does not only describe differences in means, but also reflects on whether
the resulting groups are stable, interpretable, and useful for the problem at hand.

Alternative solutions
The exercise is intentionally broad. The grading should therefore reward defensible reasoning, not one
hidden answer. The two alternatives below are both acceptable if argued carefully.

Alternative A.

Ward with k=3 on the first two PCs is acceptable because it separates the low-engagement profile from two
stronger-engagement subgroups. One subgroup is especially strong on sleep, exercise, and academic
outcomes, while the other looks more pressured, with higher coffee consumption and external workload.
This solution is slightly less compact numerically than k=2, but it can be defended on interpretability
grounds.

Table 6. Acceptable alternative A: PCA (2 PCs) + Ward, k=3.

Clu
ste
r

study
_hour
s

sleep
_hou
rs

lecture_a
ttendanc
e

notes_pag
es_per_we
ek

0.0  14.72  6.67

60.4

1.0  23.24  7.25

2.0  21.48  6.54

82.72

77.52

34.45

53.45

50.95

scree
n_tim
e

6.35

4.74

5.53

social_me
dia_minut
es

coffee_
per_da
y

196.72

128.52

143.9

2.07

1.96

2.32

stress
_scor
e

6.48

4.44

5.93

exercis
e_hour
s

commut
e_minut
es

part_time
_work_ho
urs

past_exa
m_avera
ge

engagem
ent_inde
x

early_class
es_per_we
ek

2.1

3.24

1.86

36.73

16.75

39.46

11.05

7.33

12.27

22.85

26.11

24.99

21.0

33.36

31.43

2.37

1.0

2.46

Figure 10. Standardized mean profiles for the k=3 Ward solution.

Alternative B.

Clustering directly on the standardized original variables with Ward linkage and k=2 is also acceptable. It
yields a similar substantive contrast between a stronger-engagement group and a weaker-engagement /
more constrained group.

Table 7. Acceptable alternative B: Standardized original variables + Ward, k=2.

Clu
ste
r

study
_hour
s

sleep
_hou
rs

lecture_a
ttendanc
e

notes_pag
es_per_we
ek

0.0  20.92  7.0

1.0  15.0

6.45

76.48

61.04

50.02

32.4

scree
n_tim
e

5.17

6.65

social_me
dia_minut
es

coffee_
per_da
y

145.56

198.73

2.03

2.23

stress
_scor
e

5.23

6.7

exercis
e_hour
s

commut
e_minut
es

part_time
_work_ho
urs

past_exa
m_avera
ge

engagem
ent_inde
x

early_class
es_per_we
ek

2.71

1.78

23.79

46.25

8.52

13.59

25.2

22.68

30.63

20.5

1.63

2.65

Question 5 - Limitations and uncertainty
Any of the following would deserve full credit if explained clearly.

•  The preferred number of clusters is not unambiguous. k=2 is compact and clean, but k=3 is also

defendable on substantive grounds.

•  Average linkage gives apparently good silhouettes only because it isolates an outlier. Numerical indices

must therefore be checked alongside cluster sizes.

•  The inclusion of engagement_index introduces redundancy because it is partly built from other

academic variables. A sensitivity analysis excluding it would be reasonable.

•  early_classes_per_week is a discrete count-like variable treated numerically. That is acceptable here,

but it is still a mild modeling simplification.

•  A few awkward observations, especially on commute_minutes, study_hours, and screen_time, may

influence some distance-based solutions.

Solutions: Exercise 2

Question 1. Initial exploration and baseline model choice
Note 1: n_installations, interactive_stations, and audio_guide_usage_pct should all be positively related to
avg_visit_minutes.

Note 2: avg_crowding and queue_minutes are related and can create correlation among predictors.

Table 1. Descriptive summary

avg_visit_minutes

n_installations

avg_crowding

interactive_stations

avg_temperature_c

audio_guide_usage_pct

queue_minutes

staff_per_room

mean

26.76

21.88

37.9

3.8

21.08

42.68

15.1

2.81

promo_budget_eur

1058.16

ambient_noise_db

mean_age_visitors

64.15

37.29

std

7.73

5.84

11.0

1.77

2.17

15.78

5.58

0.82

599.76

6.52

7.43

min

8.58

9.68

14.95

0.0

16.73

5.0

2.43

1.0

176.73

51.48

20.33

max

52.0

40.0

75.0

9.0

26.52

85.0

32.0

5.5

3800.0

82.0

56.76

Fig 1. Selected predictor correlations.

One strong baseline answer is to start with all quantitative predictors and to postpone theme_type to
Question 5, as requested in the exercise. The baseline model used in this report is:

avg_visit_minutes ~ n_installations + avg_crowding + interactive_stations + avg_temperature_c +
audio_guide_usage_pct + queue_minutes + staff_per_room + promo_budget_eur + ambient_noise_db +
mean_age_visitors

This is a sensible baseline because it includes the main quantitative drivers of room experience, allows for
partial-effect interpretation, and keeps the categorical extension separate for the later question.

Question 2. Fit the baseline model and check whether it seems trustworthy

Table 2. Baseline fit summary.

n

130

Baseline
quantitative

Adj. R^2

Overall F p-value

RMSE

AIC

0.5207

5.11e-17

5.3507

815.5085

Table 3. Baseline coefficient table.

Estimate

Std. Error

Intercept

n_installations

avg_crowding

interactive_stations

avg_temperature_c

audio_guide_usage_pct

queue_minutes

staff_per_room

promo_budget_eur

ambient_noise_db

mean_age_visitors

1.2097

0.5649

-0.0638

2.099

0.5031

0.1011

-0.0938

-0.3383

0.0015

-0.0741

-0.0482

7.0929

0.0868

0.0499

0.2771

0.2284

0.0305

0.0924

0.6055

0.0009

0.0801

0.0653

t value

0.1706

6.5079

-1.2782

7.5756

2.2021

3.3133

-1.015

-0.5587

1.7831

-0.9244

-0.7377

p-value

0.8649

0.0

0.2037

0.0

0.0296

0.0012

0.3121

0.5774

0.0771

0.3571

0.4621

Baseline comment. The overall model is useful, but several warning signs should stop students from
interpreting coefficients too quickly. The adjusted R^2 is respectable rather than excellent, and the
diagnostics reveal that at least one observation exerts disproportionate influence.

Figure 2. Response against interactive stations. This plot helps anchor the basic signal and shows that observation 3 is atypical.

Figure 3. Baseline residuals vs fitted values. The most important feature is the visibly problematic case 3; there is also mild
suggestion that the linear form may not be perfect.

Figure 4. Baseline Q-Q plot. Departure from the line is driven mainly by the unusual cases.

Figure 5. Baseline scale-location plot. The spread is not disastrous, but the flagged cases deserve attention.

Figure 6. Baseline leverage vs studentized residuals. Observation 1 is high leverage but near the fitted surface, observation 2 has a
large residual with ordinary leverage, and observation 3 is clearly influential

In regression, coefficient estimates can always be computed, but substantive interpretation should be
cautious if diagnostics suggest influential observations, strong model misspecification, or serious
assumption problems. A strong analysis checks whether the model is reasonably trustworthy before
drawing conclusions.

Regression diagnostics are used to assess whether the fitted model is compatible with its main
assumptions and whether a small number of observations is distorting the results. Residuals-versus-
fitted plots are useful for checking nonlinearity and heteroscedasticity, Q-Q plots help assess
approximate normality of the residuals, and leverage/influence diagnostics help detect cases that may
disproportionately affect the estimated coefficients.

Question 3. Unusual observations and decision
Observation 1: Very high leverage, but a small studentized residual. This is unusual in predictor space but
not seriously off the fitted trend.

Observation 2: Large negative residual, but ordinary leverage. This is a response outlier and is worth
discussing, but it is not the main driver of the fit.

Observation 3: High leverage, very large residual. This is the most defensible case to remove and refit.

Recommended decision(s):

-  Deal with influential points: Remove observation 3 and refit. This is the recommended solution as

Observation 3 is a higly influential point.

-  Discuss observation 1 and decide whether to remove it: leverage alone is not a deletion criterion.
Removing it or not would be acceptable either way, but it’s important to discuss that this point
alone might not be distorting the model. One could mention that an outlier point might be worth
investigating to understand whether its outlierness is due to possible measurement error (worth
removing) or has a plausible cause.

-  discuss observation 2 and decide whether to remove it: Both decisions are acceptable, but
removing an outlier with low leverage is not mandatory, this should be acknowledged.

An outlier has an unusual response value relative to the fitted trend.
A high-leverage point is unusual in predictor space.
An influential observation is one whose presence materially changes the fitted model.
These are related but not identical concepts, and they do not imply the same action.

Question 4. Refit after removing the influential observation

Table 4. Baseline vs refit after removing observation 3.

Model

Baseline
quantitative

Refit after removing
obs 3

n

130.0

129.0

Adj. R^2

Overall F p-value

RMSE

AIC

0.5207

0.5991

0.0

0.0

5.3507

4.7038

815.5085

776.0706

Table 5. Refit coefficient table after removing observation 3.

Estimate

Std. Error

Intercept

n_installations

avg_crowding

interactive_stations

avg_temperature_c

audio_guide_usage_pct

queue_minutes

staff_per_room

promo_budget_eur

ambient_noise_db

mean_age_visitors

6.7801

0.4841

-0.0838

2.2146

0.345

0.1334

-0.2021

0.3709

0.0002

-0.1248

0.0206

6.3042

0.0775

0.044

0.2443

0.2025

0.0274

0.0832

0.5452

0.0008

0.071

0.0586

t value

1.0755

6.2477

-1.9054

9.0635

1.7033

4.8751

-2.4287

0.6802

0.1906

-1.7589

0.3523

p-value

0.2844

0.0

0.0592

0.0

0.0911

0.0

0.0167

0.4977

0.8492

0.0812

0.7253

Figure 7. Refit residuals vs fitted values after removing observation 3. The plot is visibly cleaner.

Figure 8. Refit Q-Q plot. Approximate normality is more plausible after removing the influential case.

Figure 9. Refit scale-location plot. Variance looks more stable.

Figure 10. Refit leverage vs studentized residuals. Observation 1 still has leverage, but it no longer threatens the fit.

Interpretation should become more confident at this stage. The refit is more coherent: adjusted R^2
improves materially, RMSE decreases, and several coefficients move closer to the intended data-generating
structure. In particular, staff_per_room changes sign from slightly negative in the baseline fit to positive in
the refit.

n_installations: Holding the other predictors fixed, one additional installation is associated with about 0.48
extra minutes in average visit duration.

interactive_stations: Holding the other predictors fixed, one additional interactive station is associated
with about 2.21 extra minutes on average. This is one of the strongest and clearest effects in the model.

queue_minutes: Holding the other predictors fixed, one extra minute of queue time is associated with
roughly 0.20 fewer visit minutes on average.

audio_guide_usage_pct: A one-point increase in audio-guide usage percentage is associated with roughly
0.13 extra visit minutes, all else equal.

A high-grade answer may note that promo_budget_eur, mean_age_visitors, and even staff_per_room are
weak in the cleaned quantitative model.

In a multiple linear regression model, each coefficient measures the expected change in the response
associated with a one-unit increase in that predictor, holding the other predictors fixed. This is the key
conceptual difference from a simple marginal association: the coefficient should be interpreted as an
adjusted or partial effect.

Question 5. Extension with the categorical variable theme_type
To answer Question 5, keep the cleaned dataset and add the categorical variable through indicator coding.
Using standard coding, the reference category is history. The coefficients for science and immersive
therefore represent average differences relative to history, holding the quantitative predictors fixed.

When adding categories in a linear model, the coefficient of a category represents the expected
difference in the response relative to the reference category, holding the quantitative predictors fixed.

Table 6. Refit with theme_type added.

Model

n

Refit + theme_type

129.0

Adj. R^2

0.7316

Overall F p-value

RMSE

0.0

3.8487

AIC

726.101

Table 7. Selected coefficients from the final model with theme_type.

Intercept

Estimate

16.7933

C(theme_type)[T.science]

2.9409

C(theme_type)[T.immersive]  7.7394

n_installations

interactive_stations

audio_guide_usage_pct

queue_minutes

ambient_noise_db

0.3801

1.8909

0.1073

-0.3758

-0.1892

Std. Error

5.3966

0.8569

0.9992

0.0673

0.2049

0.0227

0.0721

0.06

t value

3.1118

3.432

7.7458

5.6506

9.2278

4.7333

-5.211

-3.1552

p-value

0.0023

0.0008

0.0

0.0

0.0

0.0

0.0

0.002

Figure 11. Average visit duration by theme type in the cleaned data.

Reference category: history

Science coefficient: Relative to history, science days are associated with about 2.94 extra visit minutes on
average, holding the other predictors fixed.

Immersive coefficient: Relative to history, immersive days are associated with about 7.74 extra visit
minutes on average, holding the other predictors fixed.

Adding theme_type substantially improves fit. This is a good place for students to explain that a categorical
variable shifts the expected mean response by category, relative to the chosen reference level, rather than
changing the slope of the quantitative predictors.

Question 6. Linearity, uncertainty, and limitations

Figure 12. Response against temperature. The relationship is broadly mild, but the cloud hints that a simple linear term may not
capture the full pattern.

A good answer to Question 6 does not need to fit a nonlinear model, but it should mention that
temperature is a plausible source of mild nonlinearity. In this dataset the true signal contains a gentle
concave pattern around a comfortable temperature.

Remaining uncertainty: The final model is more trustworthy than the baseline model, but conclusions are
still conditional on the linear specification.

Correlated predictors: avg_crowding and queue_minutes are related, which can make some adjusted
effects less stable than marginal relationships.

Practical vs statistical significance: Some predictors may be statistically weak while still being operationally
interesting, and vice versa.

Linearity in regression does not mean that the response and predictors must look perfectly straight in
raw plots. It means that the conditional mean of the response is modeled as a linear combination of the
included terms. Diagnostic patterns may suggest that one predictor would be better represented by a
transformed or nonlinear term, even if the overall model is still broadly useful.

Final notes
The exercise is intentionally open. Full or nearly full credit should not depend on reproducing one exact
workflow, as long as the student reasoning is statistically coherent. The main workflow should remain the
same: fit a baseline model, diagnose potential problems, decide how to handle unusual observations, refit if
appropriate, and then extend the model. Within that structure, several different decisions may still deserve
high credit if they are statistically coherent.


