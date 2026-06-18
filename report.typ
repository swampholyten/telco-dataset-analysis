// ── Page & text setup ─────────────────────────────────────────────────────
#set document(title: "Telco Customer Churn — Applied Statistics")
#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 3cm),
  numbering: "1",
  number-align: center + bottom,
)
#set text(size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1.")
#set figure(placement: none)
#set table(inset: (x: 6pt, y: 5pt), stroke: 0.5pt)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(0.8em)
  it
  v(0.4em)
}
#show heading.where(level: 2): it => {
  v(0.6em)
  it
  v(0.3em)
}

// ── Title page ───────────────────────────────────────────────────────────
#align(center)[
  #v(5cm)
  #text(size: 22pt, weight: "bold")[Telco Customer Churn Analysis]

  #v(1.2em)
  #text(size: 14pt)[Applied Statistics --- A.Y. 2025/2026]

  #v(0.6em)
  #text(size: 12pt, style: "italic")[Ninja Six]

  #v(0.6em)
  #text(size: 11pt)[June 2026]
]

#pagebreak()

// ── Table of contents ────────────────────────────────────────────────────
#outline(depth: 3, indent: auto)

#pagebreak()

// ═══════════════════════════════════════════════════════════════════════
= Dataset Description

== Overview

The dataset records service subscriptions, billing details, and churn
status for _7,043 residential customers_ of a California
telecommunications company. It contains _21 variables_ spanning
demographics, contracted services, billing preferences, and the binary
outcome `Churn` (whether the customer left within the last month).

== Variable Table

#figure(
  table(
    columns: (2.6cm, 2.8cm, 1fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Variable*], [*Type*], [*Description / Values*]),
    [`customerID`],       [ID],              [Unique identifier --- dropped before modelling],
    [`gender`],           [Binary cat.],     [Female / Male],
    [`SeniorCitizen`],    [Binary (0/1)],    [Whether the customer is 65 or older],
    [`Partner`],          [Binary cat.],     [Has a partner: Yes / No],
    [`Dependents`],       [Binary cat.],     [Has dependents: Yes / No],
    [`tenure`],           [Numeric (months)],[Months as customer (range 1--72)],
    [`PhoneService`],     [Binary cat.],     [Has phone service: Yes / No],
    [`MultipleLines`],    [3-level cat.],    [No / Yes / No phone service],
    [`InternetService`],  [3-level cat.],    [DSL / Fiber optic / No],
    [`OnlineSecurity`],   [3-level cat.],    [No / Yes / No internet service],
    [`OnlineBackup`],     [3-level cat.],    [No / Yes / No internet service],
    [`DeviceProtection`], [3-level cat.],    [No / Yes / No internet service],
    [`TechSupport`],      [3-level cat.],    [No / Yes / No internet service],
    [`StreamingTV`],      [3-level cat.],    [No / Yes / No internet service],
    [`StreamingMovies`],  [3-level cat.],    [No / Yes / No internet service],
    [`Contract`],         [3-level cat.],    [Month-to-month / One year / Two year],
    [`PaperlessBilling`], [Binary cat.],     [Yes / No],
    [`PaymentMethod`],    [4-level cat.],    [Bank transfer (auto) / Credit card (auto) / Electronic check / Mailed check],
    [`MonthlyCharges`],   [Numeric (USD)],   [Current monthly bill (18.25--118.75)],
    [`TotalCharges`],     [Numeric (USD)],   [Total charged over entire tenure (≈ tenure × MonthlyCharges)],
    [`Churn`],            [Binary target],   [Whether the customer left: Yes / No → encoded 1 / 0],
  ),
  caption: [Variable descriptions for the IBM Telco Customer Churn dataset.],
  kind: table,
)

== Numerical Summary

#figure(
  table(
    columns: (2.8cm, auto, auto, auto, auto, auto, auto),
    fill: (_, y) => if y == 0 { luma(220) } else { white },
    table.header([*Variable*], [*Mean*], [*Std*], [*Min*], [*Q25*], [*Median*], [*Max*]),
    [`tenure`],         [32.42],    [24.55],   [1],      [9],      [29],      [72],
    [`MonthlyCharges`], [\$64.80],  [\$30.09], [\$18.25],[\$35.59],[\$70.35], [\$118.75],
    [`TotalCharges`],   [\$2 283],  [\$2 267], [\$18.80],[\$401],  [\$1 397], [\$8 685],
  ),
  caption: [Descriptive statistics for the three numeric variables (n = 7,032 after cleaning).],
  kind: table,
)

== Data Cleaning

Three cleaning steps were applied before any analysis:

+ *`TotalCharges` type fix.* The column is stored as a string object. Eleven
  rows contain only whitespace (customers with `tenure = 0`, recently
  onboarded). These were coerced to `NaN` via
  `pd.to_numeric(..., errors='coerce')` and dropped, leaving *7,032 rows*.

+ *`customerID` removed.* The identifier carries no predictive signal and was
  dropped to prevent accidental leakage.

+ *`Churn` encoded as 0/1.* The string values "No" / "Yes" were mapped to
  integers for compatibility with scikit-learn classifiers and metric
  functions.

*After cleaning:* 7,032 rows × 20 columns. Overall churn rate: *26.6%*
(1,869 churned customers).

#block(
  fill: luma(238),
  inset: 10pt,
  radius: 4pt,
  [*Collinearity note.* `TotalCharges` correlates with
  `tenure × MonthlyCharges` at $r = 0.9996$. It is excluded from all
  regression and classification models to avoid near-perfect
  multicollinearity.],
)

// ═══════════════════════════════════════════════════════════════════════
= Exploratory Data Analysis

#figure(
  image("figures/fig_01_eda_main.png", width: 100%),
  caption: [Six-panel EDA overview of key churn predictors.],
)

Key observations from the EDA:

- *Contract type* is the strongest univariate predictor: month-to-month
  customers churn at ~43% versus ~11% (one year) and ~3% (two year).
- *Internet service:* fiber optic customers churn at ~42%, DSL at ~19%,
  no-internet customers at ~7%.
- *Payment method:* electronic check users have the highest churn rate
  (~45%), likely correlated with month-to-month contracts.
- *Tenure* shows a strong negative relationship with churn: most churners
  leave within the first 12--18 months.
- *Monthly charges* are on average higher for churners (~\$74 vs.\ \$61).
- *Senior citizens* churn at ~42% versus ~24% for non-seniors.

#figure(
  image("figures/fig_02_eda_services.png", width: 100%),
  caption: [Churn rates by add-on service subscription status, shown as
  three separate groups. *Red* (No): customer has internet but did not
  subscribe to this add-on --- highest churn (~34--42%). *Blue* (Yes):
  customer subscribed to the add-on --- lower churn (~15--30%). *Green*
  (No internet service): customer has no internet at all --- lowest churn
  (7.4% for all six services, identical because it is the same 1,520
  customers in every panel).],
)

The plot reveals:

- *No internet service* customers (green) churn at only 7.4% --- the same
  value across all six add-ons because it is exactly the same 1,520
  customers in every column. They are not a "non-subscriber" in the usual
  sense; they simply have no internet product at all.
- *"No" subscribers* (red) --- customers who have internet but skipped the
  add-on --- churn at 34--42%, the highest risk group.
- *"Yes" subscribers* (blue) churn at 15--30%, roughly half the rate of
  the "No" group. Security and support add-ons show the largest gap
  (OnlineSecurity: 41.8% vs 14.6%; TechSupport: 41.6% vs 15.2%),
  while streaming services show a smaller gap (both groups ~30--34%).

This also explains the identical bars in the correlation chart: all six
`_No internet service` dummies are the same 1,520 customers, so they
produce the same r = −0.2276 with Churn.

== Correlation Analysis

To quantify the associations observed above, Figure 3 shows (left) the Pearson
correlation matrix for the three numeric variables plus the binary `Churn`
indicator, and (right) the top 20 features by absolute point-biserial
correlation with `Churn`.

#figure(
  image("figures/fig_21_correlations.png", width: 100%),
  caption: [Left: Pearson correlation matrix for numeric variables + Churn.
  `TotalCharges` is essentially `tenure × MonthlyCharges` ($r = 0.9996$),
  confirming its exclusion from models. Right: top 20 features by
  |point-biserial r| with Churn. Red bars increase churn risk; blue bars
  are protective. Contract type and internet service dominate.],
)

Key quantitative take-aways from the correlation analysis:

- `TotalCharges` correlates with `tenure × MonthlyCharges` at $r = 0.9996$
  --- near-perfect collinearity confirms it must be excluded from regression
  and classification models.
- `Contract_Month-to-month` shows the highest positive correlation with
  `Churn`, while `Contract_Two year` is the strongest negative correlate.
- `tenure` has the second-strongest negative association with `Churn`:
  each additional month as a customer is associated with lower churn
  probability.
- Fiber optic internet, electronic check payment, and paperless billing
  are positively associated with churn.
- The six internet add-on services (Online Security, Tech Support, etc.)
  are all negatively correlated with `Churn` --- consistent with the EDA
  observation that these services roughly halve the churn rate.

=== Why six features share the same correlation value

In the right panel, the following seven entries all show *r = −0.2276*:

#figure(
  table(
    columns: (3fr, 1fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Feature*], [*r with Churn*]),
    [`InternetService_No`],                    [−0.2276],
    [`OnlineSecurity_No internet service`],    [−0.2276],
    [`OnlineBackup_No internet service`],      [−0.2276],
    [`DeviceProtection_No internet service`],  [−0.2276],
    [`TechSupport_No internet service`],       [−0.2276],
    [`StreamingTV_No internet service`],       [−0.2276],
    [`StreamingMovies_No internet service`],   [−0.2276],
  ),
  caption: [Seven features with identical point-biserial correlation with Churn --- all encode the same binary fact.],
  kind: table,
)

*Why are they identical?* The six add-on columns (OnlineSecurity, TechSupport,
OnlineBackup, DeviceProtection, StreamingTV, StreamingMovies) each store the
string `"No internet service"` for every customer whose `InternetService`
is `"No"` — the dataset's way of marking that the add-on is inapplicable.
When `pd.get_dummies` one-hot encodes each column, it creates a separate
`_No internet service` dummy for each, but all six dummies equal 1 for
*exactly the same 1,526 customers* (those with no internet service).
They are *perfectly collinear* with each other and with `InternetService_No`.
All seven variables express a single binary fact: *this customer has no
internet service.*

*Why this is a modelling problem --- not just a curiosity:*

Lasso's "select one, zero the rest" property holds only when features are
_imperfectly_ correlated. Under perfect collinearity (|r| = 1.000) the L1
objective has infinitely many minimisers; the solver converges to the
symmetric equal-split solution (all seven features get −0.094 each), which
is Ridge-like behaviour --- not feature selection. The estimated effect of
`InternetService_No` would appear 6× smaller than it truly is, diluted
across seven identical columns.

A second collinearity exists between `PhoneService_Yes` and
`MultipleLines_No phone service` (|r| = 1.000 verified). Every customer
without phone service has both simultaneously.

*Fix applied before RQ1 modelling:* The six add-on columns are recoded
(`'No internet service'` → `'No'`), making them binary and removing the
six redundant dummies. `PhoneService` is dropped since `MultipleLines`
already encodes three levels (no phone / single line / multiple lines). The
design matrix shrinks from 29 to *22 clean features* with zero
perfect-collinearity pairs remaining.

These associations motivate the feature set and model interpretation in RQ1.

// ═══════════════════════════════════════════════════════════════════════
= RQ1 --- Churn Risk Factors & Retention Targeting

_Which customer, service, and contract characteristics are most strongly
associated with churn, and which levers should a telecom operator
prioritize?_

*Method sequence:* A logistic regression baseline establishes interpretable
odds ratios; Lasso (L1) regularisation performs embedded feature selection;
Random Forest provides a non-parametric benchmark and importance ranking.
All models use a shared preprocessing pipeline (`StandardScaler` +
`OneHotEncoder` inside `ColumnTransformer`) and a stratified 80/20
train/test split. This three-model progression (linear → penalised linear →
non-parametric) allows direct comparison and cross-validation of which
features are robustly predictive across model families.

*Pipeline discipline:* All preprocessing is placed inside a `Pipeline`
object so that during cross-validation the scaler and encoder are fitted
_only_ on the training fold and applied to the validation fold --- never
the reverse. This prevents data leakage that would artificially inflate
held-out performance estimates.

== Preprocessing

*Collinearity fix (applied before the pipeline):* A structural audit of
the raw one-hot encoding reveals two groups of perfectly collinear features
(|r| = 1.000). (1) Six add-on service columns each store `'No internet
service'` for the same 1,520 customers, producing six dummies identical to
`InternetService_No`; recoded to binary Yes/No before encoding. (2)
`PhoneService_Yes` = 1 − `MultipleLines_No phone service` exactly;
`PhoneService` dropped since `MultipleLines` encodes all three levels.
Result: *22 clean features*, zero perfect-collinearity pairs.

Numerical predictors (`tenure`, `MonthlyCharges`) are standardised; all
categorical predictors are one-hot encoded with `drop='first'`. Everything
lives inside a `Pipeline` so cross-validation folds never see information
from the held-out fold --- no leakage.

*Training set:* 5,625 observations (26.6% churn) | *Test set:* 1,407
observations (26.6% churn).

== Logistic Regression Baseline

*Why logistic regression?* With a binary outcome (Churn = 0/1), logistic
regression models the log-odds of churn as a linear combination of
predictors. It is the natural starting point: interpretable through
exponentiated coefficients (odds ratios), computationally efficient, and
provides the linear reference against which the regularised and
non-parametric models are benchmarked.

*Why `class_weight='balanced'`?* The dataset has 26.6% churners. Without
correction, a classifier optimising for accuracy would predict "No Churn"
almost always (~80% accuracy while catching almost no real churners).
Balanced weighting up-weights the minority class proportionally. AUROC is
used as the primary metric because it is threshold-independent and robust to
class imbalance.

A logistic regression with `class_weight='balanced'` achieves *test
AUROC = 0.833*.

#figure(
  image("figures/fig_03_lr_cm_roc.png", width: 100%),
  caption: [Logistic Regression: confusion matrix (left) and ROC curve
  (right). Balanced weights prioritise recall for churners (0.79) at
  the cost of precision (0.49).],
)

#figure(
  image("figures/fig_04_lr_odds.png", width: 96%),
  caption: [Exponentiated logistic regression coefficients (odds ratios).
  Values above 1 increase churn odds; values below 1 decrease them.],
)

#figure(
  table(
    columns: (1fr, auto, 1.8fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Feature*], [*OR*], [*Direction*], [*Interpretation*]),
    [`Contract_Two year`],              [0.238], [↓↓ (OR ≪ 1)], [Strongest single churn deterrent],
    [`Contract_One year`],              [0.456], [↓],            [Also substantially reduces churn odds],
    [`InternetService_No`],             [0.378], [↓↓],           [No-internet customers churn far less (7% vs 42% fiber); _was distorted to 0.856 before collinearity fix_],
    [`tenure`],                         [0.468], [↓↓],           [More tenure → lower churn odds],
    [`OnlineSecurity_Yes`],             [0.707], [↓],            [Security add-on reduces churn odds],
    [`TechSupport_Yes`],                [0.740], [↓],            [Support add-on reduces churn odds],
    [`InternetService_Fiber optic`],    [2.908], [↑↑],           [Fiber customers have ~3× higher churn odds vs DSL baseline],
    [`PaymentMethod_Electronic check`], [1.512], [↑],            [Non-automatic payment → higher churn],
    [`MultipleLines_No phone service`], [1.394], [↑],            [No phone bundle → 39% higher churn odds vs single-line],
    [`SeniorCitizen_1`],                [1.225], [↑],            [Senior citizens have elevated churn odds],
  ),
  caption: [Logistic regression odds ratios. OR \< 1 = churn deterrent; OR \> 1 = churn risk. `InternetService_No` OR was severely underestimated (0.856) before the collinearity fix; corrected value is 0.378.],
  kind: table,
)

== Lasso (L1) Feature Selection

*Why Lasso?* After the collinearity pre-processing step the design matrix
contains 22 features with no perfect collinearity. Lasso adds an L1 penalty
proportional to the sum of absolute coefficients, which shrinks genuinely
uninformative features _exactly to zero_, performing automatic feature
selection while preserving predictive performance. (Under perfect collinearity
Lasso's selection property breaks down --- the solver distributes the
coefficient equally, mimicking Ridge. The fix applied before this stage
restores the guarantee.) The regularisation strength is controlled by $C$
(smaller $C$ = stronger penalty); we select the $C$ that maximises held-out
AUROC via 5-fold stratified CV.

L1-penalised logistic regression with `C` tuned over a log-spaced grid
via 5-fold stratified CV selects *best C = 0.2069* and achieves *test
AUROC = 0.835*.

#figure(
  image("figures/fig_05_lasso_cv.png", width: 85%),
  caption: [Mean CV AUROC ± 1 SD across the C grid. Performance
  plateaus above C ≈ 0.2.],
)

Lasso *retains 18 features* and *zeroes out 4*:

#figure(
  table(
    columns: (1fr, 1.6fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Zeroed feature*], [*Interpretation*]),
    [`gender_Male`],                        [Gender has no independent predictive value],
    [`DeviceProtection_Yes`],               [Marginal after OnlineSecurity and TechSupport are included],
    [`PaymentMethod_Credit card (auto)`],   [Automatic card users behave like bank-transfer users],
    [`PaymentMethod_Mailed check`],         [Indistinguishable from reference payment category],
  ),
  caption: [Features shrunk to zero by Lasso.],
  kind: table,
)

Top retained features by absolute coefficient:

#figure(
  table(
    columns: (2fr, auto, 1.6fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Feature*], [*Lasso coef.*], [*Interpretation*]),
    [`Contract_Two year`],                   [−1.380], [Strongest churn reducer],
    [`InternetService_Fiber optic`],         [+0.775], [Highest positive risk factor],
    [`tenure`],                              [−0.765], [Longer tenure → lower churn],
    [`Contract_One year`],                   [−0.750], [Second-strongest protective contract],
    [`InternetService_No`],                  [−0.658], [No-internet customers churn far less; correctly isolated after collinearity fix],
    [`MultipleLines_No phone service`],      [+0.492], [No phone bundle → more likely to churn; isolated after dropping redundant PhoneService],
    [`OnlineSecurity_Yes`],                  [−0.383], [Value-added services reduce churn],
    [`PaymentMethod_Electronic check`],      [+0.358], [Higher-risk payment method],
    [`TechSupport_Yes`],                     [−0.332], [Value-added services reduce churn],
  ),
  caption: [Top Lasso-retained features (standardised predictors). 18 of 22 features retained; 4 zeroed.],
  kind: table,
)

== Random Forest

*Why Random Forest?* Logistic regression and Lasso assume a _linear_
relationship between features and log-odds. A Random Forest makes no such
assumption: it averages predictions from many decision trees, each built on
a bootstrap sample and a random feature subset, naturally capturing
non-linear interactions. Two additional advantages: (1) each tree uses ~63%
of the data for fitting, leaving ~37% as *out-of-bag (OOB)* samples --- a
free generalisation estimate with no extra cross-validation cost; (2) Gini
importance provides an independent feature ranking to cross-validate the
Lasso ordering.

300-tree Random Forest with OOB evaluation and 5-fold CV selects *max\_depth = 10, min\_samples\_leaf = 10*. OOB score = 0.804; *test AUROC = 0.839*.

#figure(
  image("figures/fig_06_rf_importance.png", width: 96%),
  caption: [Random Forest: top 15 features by mean decrease in Gini
  impurity. `tenure` and `Contract_Two year` dominate, consistent with
  the logistic regression.],
)

== Model Comparison

#figure(
  table(
    columns: (2fr, auto),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Model*], [*Test AUROC*]),
    [Logistic Regression],          [0.833],
    [Lasso LR (tuned C = 0.2069)],  [0.835],
    [Random Forest (tuned)],         [*0.839*],
  ),
  caption: [RQ1 model comparison on the held-out test set.],
  kind: table,
)

#figure(
  image("figures/fig_07_rq1_roc.png", width: 85%),
  caption: [ROC curves for all three RQ1 models. The near-identical curves
  confirm that the linear and non-parametric models capture the same
  underlying signal.],
)

=== Cross-Model Feature Agreement

Figure 8 places the three models' importance rankings side by side to verify
that the top predictors are consistent across model families --- a signal is
more robust if an interpretable linear model and a non-parametric ensemble
both identify it as important.

#figure(
  image("figures/fig_22_feature_comparison.png", width: 100%),
  caption: [Feature importance comparison across LR |log-odds|, Lasso
  |coefficient|, and RF Gini importance (top 12 features each). Features
  that appear prominently in all three panels have robust, model-family-
  independent associations with churn.],
)

Observe that `Contract_Two year`, `tenure`, `InternetService_Fiber optic`,
`Contract_One year`, `InternetService_No`, and `OnlineSecurity_Yes` appear
in the top positions of all three rankings. This cross-model consensus
provides strong evidence that these features carry genuine predictive signal
rather than artifacts of any single modelling approach. Note that
`InternetService_No` now appears prominently because the collinearity fix
concentrates its coefficient in one place rather than splitting it across
seven identical dummies.

*RQ1 answer:* Contract type (month-to-month is the dominant risk; two-year
the strongest deterrent), fiber optic internet, short tenure, electronic
check payment, and absence of value-added services are the principal churn
drivers. Retention targeting should prioritise contract-upgrade incentives
and bundling security / support add-ons for new fiber customers.

// ═══════════════════════════════════════════════════════════════════════
= RQ2 --- Customer Segmentation & Churn Profiling

_Do distinct customer profiles emerge from service usage and billing
patterns, and do these profiles differ systematically in churn rate and
revenue at risk?_

*Method sequence:* PCA reduces the encoded feature matrix to a compact
representation; K-Means and Ward hierarchical clustering are compared using
silhouette scores; the chosen solution is profiled by churn rate, monthly
charges, tenure, and estimated CLV at risk.

*Why PCA before clustering?* After one-hot encoding with the
collinearity-corrected feature set the feature matrix has 26 columns. Clustering in this high-dimensional space has two problems: (1)
correlated features are double-counted in Euclidean distance --- for instance,
all six internet add-on columns correlate with `InternetService` and with
each other; and (2) the "curse of dimensionality" makes all pairwise
distances converge, reducing cluster separation. PCA decorrelates features
and compresses shared variance into a small number of orthogonal axes,
giving K-Means and Ward HC a cleaner input space.

== PCA

The 7,032-row standardised and one-hot-encoded matrix (using
`drop='if_binary'` for unsupervised encoding) is reduced by PCA:

#figure(
  table(
    columns: (auto, auto, auto),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*PC*], [*Explained Variance*], [*Cumulative*]),
    [PC1],  [28.6%], [28.6%],
    [PC2],  [18.8%], [47.5%],
    [PC3],  [8.2%],  [55.7%],
    [PC4],  [4.6%],  [60.4%],
    [PC5],  [3.8%],  [64.2%],
    [⋮],    [⋮],     [⋮],
    [PC11], [---],   [≥ 80.0%],
  ),
  caption: [PCA explained variance. Eleven PCs are required to explain 80% of total variance.],
  kind: table,
)

Eleven PCs are needed to explain 80% of variance, confirming moderate
dimensionality. The first five PCs (64.2%) are used as the clustering
space, balancing compression against information retention.

#figure(
  image("figures/fig_08_pca_scree.png", width: 100%),
  caption: [Left: scree plot --- variance drops sharply after PC2. Right:
  PC1 vs PC2 coloured by churn label; churners overlap but concentrate
  toward higher PC1 values.],
)

#figure(
  image("figures/fig_09_pca_loadings.png", width: 96%),
  caption: [PCA loadings heatmap (PC1--PC3, top 18 features). PC1 is a
  "service richness" axis; PC2 contrasts long-tenure / high-spend customers
  against recent / basic-plan customers.],
)

=== PCA Biplot

The biplot (Figure below) overlays the loading arrows on the PC1--PC2
scatter, making the geometric relationship between customers and features
visible simultaneously. Arrow direction shows how each original feature
pulls observations along the PC axes; features with arrows pointing in the
same direction are positively correlated in PCA space.

#figure(
  image("figures/fig_23_pca_biplot.png", width: 96%),
  caption: [PCA biplot (900-observation subsample, coloured by churn label).
  Arrows show loadings for the top 12 features by magnitude. Observe that
  tenure and contract arrows point left (low PC1 = short tenure =
  higher churn, visible as red points concentrating on the right).
  Internet add-on service arrows cluster together --- these features are
  nearly parallel, confirming their high mutual correlation.],
)

Key observations from the biplot:

- *Churner concentration:* red (Churn = 1) points concentrate along one
  direction, while blue points spread more broadly --- the PC1--PC2 projection
  partially separates churn status even without using the label.
- *Add-on services bundle together:* OnlineSecurity, TechSupport,
  OnlineBackup arrows point in the same direction, confirming the high
  within-group correlation seen in the correlation heatmap.
- *Tenure and two-year contract* arrows point in the protective direction,
  consistent with their negative correlations with `Churn` from the
  correlation analysis.

== Clustering Comparison

#figure(
  table(
    columns: (2fr, auto, auto, 1.8fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Method*], [*k*], [*Silhouette*], [*Cluster sizes*]),
    [K-Means], [2],   [*0.454*], [5 512, 1 520],
    [K-Means], [*3*], [0.400],   [3 059, 2 453, 1 520],
    [K-Means], [4],   [0.380],   [1 987, 1 984, 1 541, 1 520],
    [Ward HC], [2],   [0.454],   [5 512, 1 520],
    [Ward HC], [3],   [0.379],   [3 310, 2 202, 1 520],
    [Ward HC], [4],   [0.350],   [2 202, 1 823, 1 520, 1 487],
  ),
  caption: [Silhouette scores for K-Means and Ward HC at k = 2, 3, 4.],
  kind: table,
)

*Why compare two algorithms?* K-Means minimises within-cluster sum of
squares and assumes approximately spherical clusters. Ward hierarchical
clustering minimises variance at each merge step and can accommodate
non-spherical shapes. Consistent results across both methods provide stronger
evidence that the structure is real rather than an artifact of one algorithm.

Although k = 2 yields the highest silhouette, it merges two meaningfully
different customer types into one group. K-Means k = 3 (silhouette = 0.400)
is chosen because the churn profiles of the three clusters are sharply
differentiated (7%, 15%, 45%), providing actionable segmentation. Ward HC
gives slightly lower silhouette scores at all k values on this PCA
embedding.

*Substantive preference over mathematical criterion:* Silhouette is a
mathematical criterion; business relevance must also guide the final choice.
At k = 3, the two clusters that k = 2 merges have very different churn rates
(45% vs 15%) and CLV at risk (\$820 vs \$4,623) --- they require different
retention strategies and cannot be treated as one segment.

#figure(
  image("figures/fig_10_dendro_silhouette.png", width: 100%),
  caption: [Left: Ward dendrogram on a 400-observation subsample showing a
  clear three-cluster structure. Right: silhouette vs k for both
  methods.],
)

#figure(
  image("figures/fig_11_kmeans_clusters.png", width: 82%),
  caption: [K-Means k = 3 solution in PC1--PC2 space (silhouette = 0.400).
  Three visually separable groups.],
)

== Cluster Profiles

#figure(
  image("figures/fig_12_cluster_profiles.png", width: 100%),
  caption: [Six-panel cluster profiles: churn rate, monthly charges, tenure,
  fiber fraction, month-to-month fraction, and CLV at risk per
  cluster.],
)

#figure(
  table(
    columns: (2.8cm, auto, auto, auto),
    fill: (_, y) => if y == 0 { luma(220) } else { white },
    table.header([], [*Cluster 0*], [*Cluster 1*], [*Cluster 2*]),
    [*n*],                    [3 059],     [1 520],     [2 453],
    [*Churn rate*],           [*45.3%*],   [7.4%],      [15.0%],
    [*Avg monthly charges*],  [\$67.8],    [\$21.1],    [\$88.2],
    [*Avg tenure*],           [15 months], [31 months], [55 months],
    [*Fiber optic*],          [54.3%],     [0%],        [58.5%],
    [*Month-to-month*],       [90.2%],     [34.5%],     [24.2%],
    [*Senior citizen*],       [20.0%],     [3.4%],      [19.4%],
    [*Avg CLV at risk*],      [\$820],     [\$174],     [*\$4 623*],
  ),
  caption: [K-Means k = 3 cluster summary. CLV at risk is the mean of
  (MonthlyCharges × tenure) for churned customers in each cluster.],
  kind: table,
)

- *Cluster 0 --- "New High-Risk"* (n = 3,059, churn = 45.3%): Recent
  customers (~15 months) predominantly on month-to-month fiber contracts.
  Highest churn rate and largest group; priority target for contract-upgrade
  incentives.
- *Cluster 1 --- "Basic Loyal"* (n = 1,520, churn = 7.4%): Moderate-tenure
  customers with no internet service and low monthly charges (\$21). Very
  stable segment requiring only basic retention.
- *Cluster 2 --- "Established High-Value"* (n = 2,453, churn = 15%):
  Long-tenure (~55 months), high-spend (\$88/mo) customers. Moderate churn
  rate, but *CLV at risk (\$4,623) is over five times that of Cluster 0* ---
  critical to retain proactively.

=== Standardised Cluster Profiles

To place all metrics on a common scale (removing unit differences between
%, months, and USD), Figure below shows z-scores relative to the global
column means and standard deviations. A bar above zero means the cluster
scores above the global average on that metric; below zero means below.

#figure(
  image("figures/fig_24_cluster_std_profiles.png", width: 100%),
  caption: [Standardised cluster profiles (z-scores). Cluster 0 is
  strongly above average on churn rate, fiber optic, and month-to-month
  contract, but well below average on tenure. Cluster 2 is above average
  on charges and tenure but below average on churn rate. Cluster 1 is
  below average on almost every metric --- the "basic, stable" segment.],
)

The z-score chart makes the between-cluster contrasts crisp: Cluster 0 is
uniformly high-risk (high churn, high fiber, high MTM, low tenure), Cluster
2 is the established high-value customer, and Cluster 1 is the low-engagement
baseline across all dimensions.

// ═══════════════════════════════════════════════════════════════════════
= RQ3 --- Service Pricing Structure

_How much does each service add-on contribute to a customer's monthly
charges, and is the pricing structure consistent and additive?_

*Method:* Ordinary Least Squares regression (statsmodels) with
`MonthlyCharges` as the response. The "No internet service" and "No phone
service" values in add-on columns are recoded to "No" before one-hot
encoding (with `drop_first=True`) to avoid perfect collinearity with
`InternetService_No`. `TotalCharges` and `Churn` are excluded.

*Why OLS?* The EDA shows that monthly charges span a wide range
(\$18--\$119) that appears to be determined by which services each customer
subscribes to. We hypothesise a _purely additive pricing model_: each
service contributes a fixed, independent amount regardless of what else is
subscribed. OLS estimates these partial contributions while holding all other
services fixed.

*Why no train/test split?* This is an _inferential_ question (what are the
price increments?) rather than a _predictive_ one (how well can we predict
charges for new customers?). We fit on all 7,032 observations to obtain
maximally precise coefficient estimates. The near-perfect R² we observe is
_expected_, not a sign of overfitting --- it confirms that charges are a
deterministic linear function of subscribed services.

*Encoding detail:* "No internet service" and "No phone service" values in
add-on columns are recoded to "No" before `pd.get_dummies`. Without this
step, they would be perfectly collinear with `InternetService_No` and
`PhoneService_No`, making the design matrix rank-deficient.

== Model Fit

*R² = 0.999*, adjusted R² = 0.999, F-statistic p < 0.001, n = 7,032.

The near-perfect R² confirms that `MonthlyCharges` is essentially a
*deterministic linear function* of subscribed services --- this is a pricing
schedule, not a stochastic model. OLS acts here as a clean decomposition
tool.

#figure(
  image("figures/fig_25_ols_actual_vs_pred.png", width: 80%),
  caption: [Actual vs predicted `MonthlyCharges`. Points lie almost exactly
  on the 45° line ($R^2 = 0.999$), confirming a near-perfect additive fit.
  Vertical bands correspond to discrete price levels (specific service
  combinations); small deviations from the line reflect minor rounding or
  promotional pricing. Residual standard deviation ≈ \$0.50.],
)

== Service Contribution Table

#figure(
  table(
    columns: (3.2cm, auto, 3cm, auto),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Service*], [*Coef. (USD)*], [*95% CI*], [*p-value*]),
    [Intercept (DSL, no phone, no add-ons)], [+24.95], [[24.86, 25.03]],   [< 0.001],
    [Fiber optic (vs DSL)],                  [+24.95], [[24.89, 25.02]],   [< 0.001],
    [No internet (vs DSL)],                  [−25.04], [[−25.14, −24.95]], [< 0.001],
    [Phone service],                         [+20.06], [[19.96, 20.15]],   [< 0.001],
    [Streaming TV],                          [+9.97],  [[9.90, 10.03]],    [< 0.001],
    [Streaming Movies],                      [+9.96],  [[9.90, 10.03]],    [< 0.001],
    [Tech Support],                          [+5.03],  [[4.97, 5.10]],     [< 0.001],
    [Device Protection],                     [+5.02],  [[4.96, 5.08]],     [< 0.001],
    [Multiple Lines],                        [+5.02],  [[4.96, 5.07]],     [< 0.001],
    [Online Security],                       [+5.01],  [[4.95, 5.08]],     [< 0.001],
    [Online Backup],                         [+4.99],  [[4.94, 5.05]],     [< 0.001],
    [Contract One year (vs MTM)],            [+0.01],  [[−0.05, 0.08]],    [0.714],
    [Contract Two year (vs MTM)],            [−0.02],  [[−0.10, 0.05]],    [0.539],
  ),
  caption: [OLS coefficients for MonthlyCharges. All service coefficients
  are highly significant; contract-length coefficients are
  indistinguishable from zero.],
  kind: table,
)

#figure(
  image("figures/fig_14_coefs.png", width: 96%),
  caption: [OLS coefficient plot with 95% confidence intervals. Service
  coefficients are precisely estimated (narrow CIs due to the
  near-deterministic pricing structure).],
)

== Regression Diagnostics

#figure(
  image("figures/fig_13_diagnostics.png", width: 100%),
  caption: [Diagnostic plots (2 × 2). Residuals vs fitted and
  scale-location show very small but non-random residuals (SD ≈ \$0.50),
  reflecting minor rounding or promotional pricing. Q-Q plot confirms
  approximate normality. 474 observations (6.7%) exceed Cook's D
  threshold of 4/n --- a consequence of the extremely small threshold at
  n ≈ 7,000; no observation is truly influential.],
)

*RQ3 answer:* Monthly charges decompose almost perfectly into a transparent
additive pricing schedule. Each streaming service adds ~\$10; security,
backup, device protection, and tech support each add ~\$5; phone service
adds ~\$20; fiber optic adds ~\$25 over the DSL baseline. Crucially,
*contract length does not affect monthly charges* (both contract
coefficients are near zero and non-significant), confirming that contract
type governs commitment level rather than price.

// ═══════════════════════════════════════════════════════════════════════
= RQ4 --- Decision Tree & Gradient Boosting

_Can tree-based interpretable methods reveal the decision logic behind
churn, and how do they compare to linear classifiers on predictive
performance?_

*Why Decision Trees?* RQ1 identified _which_ features predict churn. A
natural follow-up is _how_ these features combine into decision rules. A
shallow Decision Tree (max\_depth = 3) expresses the entire churn signal as
at most eight if-then rules --- simple enough for a retention manager to act
on without a model, and directly interpretable as customer-facing thresholds.

*Why Gradient Boosting?* A single Decision Tree has high variance (rules
change substantially across bootstrap samples). Gradient Boosting builds an
_ensemble of shallow trees sequentially_, each correcting residuals from the
previous one. It is consistently the strongest off-the-shelf method on
tabular data and provides an AUROC upper bound for the tree family.

All models use the same preprocessing pipeline and train/test split as RQ1,
enabling fair head-to-head comparison.

== Shallow Decision Tree --- Interpretable Rules

The depth-3 tree achieves test AUROC = 0.810. Standardised thresholds are
translated to raw units using the training-set statistics of `tenure`
(mean = 32.42 months, SD = 24.55 months).

#figure(
  raw(block: true,
"|--- tenure <= -0.65   [raw: <= ~16 months]
|   |--- InternetService_Fiber optic <= 0.5   (no fiber)
|   |         Predict: No Churn
|   |--- InternetService_Fiber optic >  0.5   (fiber optic)
|             Predict: Churn
|
|--- tenure >  -0.65   [raw: > ~16 months]
          Predict: No Churn  (all sub-cases)"
  ),
  caption: [Depth-3 decision tree rules. The dominant rule is:
  new customer (≤ 16 months) on fiber optic → Churn.],
)

The tree distils the entire churn signal into *one dominant rule*:
customers who are *new (≤ 16 months) AND on fiber optic* are predicted to
churn; all other profiles are predicted to stay. This aligns precisely with
the Lasso coefficients and the Cluster 0 profile from RQ2 --- the high-risk
segment is this exact intersection.

== Tuned Decision Tree & Gradient Boosting

#figure(
  table(
    columns: (2.2fr, 2fr, auto),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Model*], [*Best hyperparameters*], [*Test AUROC*]),
    [Shallow DT (depth = 3)], [fixed],                                  [0.810],
    [Tuned DT],               [max\_depth = 6, min\_samples\_leaf = 40], [0.829],
    [Gradient Boosting],      [lr = 0.05, depth = 2, subsample = 0.8],  [*0.840*],
  ),
  caption: [RQ4 model performance. Gradient Boosting achieves the
  highest AUROC.],
  kind: table,
)

#figure(
  image("figures/fig_15_tree_importances.png", width: 100%),
  caption: [Feature importances (Gini decrease) for the tuned DT (left)
  and GB (right). Both identify `tenure` and
  `InternetService_Fiber optic` as the two dominant predictors.],
)

== All-Model Comparison

#figure(
  table(
    columns: (2fr, auto),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Model*], [*Test AUROC*]),
    [Decision Tree (tuned)],    [0.829],
    [Logistic Regression],      [0.833],
    [Lasso LR (tuned)],         [0.835],
    [Random Forest (tuned)],    [0.839],
    [*Gradient Boosting*],      [*0.840*],
  ),
  caption: [Full five-model AUROC comparison on the held-out test set.],
  kind: table,
)

#figure(
  image("figures/fig_16_roc_all.png", width: 88%),
  caption: [ROC curves for all five models. Gradient Boosting achieves
  the highest AUROC (0.840); the margin over logistic regression
  (0.833) is 0.7 percentage points.],
)

*RQ4 answer:* The shallow DT confirms that churn is primarily driven by the
*new-customer × fiber optic intersection*. Gradient Boosting achieves the
best AUROC (0.840), but the improvement over logistic regression is modest
(0.7 pp), indicating the feature-outcome relationship is largely linear on
the log-odds scale. For operational deployment, logistic regression or Lasso
offers a better interpretability--performance tradeoff; GB would be
preferred only if the marginal AUROC gain translates into meaningful
business value.

// ═══════════════════════════════════════════════════════════════════════
= RQ5 --- Probabilistic Segmentation with GMM

_Do customers exhibit soft, probabilistic membership in latent segments,
and does a GMM at higher granularity reveal finer-grained risk profiles
than the K-Means solution?_

*Why GMM after K-Means?* K-Means makes two restrictive assumptions: (1)
clusters are spherical (equal variance in all PCA directions), and (2)
membership is _hard_ --- each customer belongs to exactly one cluster with
certainty. GMM relaxes both. Each component is modelled as a multivariate
Gaussian with its own covariance matrix (allowing elliptical shapes), and
every customer receives a *posterior probability* of belonging to each
component.

The soft assignments have practical value: a customer with 60% probability
in a high-churn component and 40% in a loyal component is qualitatively
different from one with 97% in the loyal component --- and may merit a
different retention offer. The certainty map below makes boundary uncertainty
visible.

*Model selection via BIC and AIC:* Both criteria reward fit while penalising
model complexity (BIC penalises more heavily than AIC for large $n$). When
both criteria agree on the same $k$, the choice is robust to criterion
selection. Gaussian Mixture Models (full covariance) are fitted on the same
PCA-5 space as RQ2. `n_init = 10` restarts guard against local optima. Soft
posterior probabilities from `predict_proba()` quantify uncertain
memberships.

== Model Selection

#figure(
  image("figures/fig_17_gmm_bic.png", width: 85%),
  caption: [BIC and AIC as a function of k. Both criteria select k = 6.],
)

Both BIC and AIC select *k = 6*, indicating that six components provide the
best balance between fit and complexity. BIC penalises model complexity more
heavily than AIC, yet both agree on k = 6.

== Soft Memberships and Uncertainty

- *5.7% of customers* have maximum posterior probability < 0.80 (uncertain
  membership).
- *Mean posterior certainty = 0.967* (SD = 0.083): the vast majority are
  cleanly assigned to one component.
- *Adjusted Rand Index vs K-Means k = 3: 0.330* --- moderate agreement,
  expected given the different number of components.

#figure(
  image("figures/fig_18_gmm_clusters.png", width: 100%),
  caption: [Left: GMM hard labels (MAP assignment) in PC1--PC2 space.
  Right: membership certainty map --- uncertain customers (yellow) appear
  mainly at cluster boundaries.],
)

== GMM Component Profiles

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, 1.6fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header(
      [*Comp.*], [*n*], [*Churn*], [*\$/mo*],
      [*Tenure*], [*Fiber*], [*MTM*], [*Profile*],
    ),
    [*C1*], [901],   [*66.3%*], [\$80], [10 mo], [100%], [99.8%], [New fiber MTM --- critical risk],
    [C3],   [428],   [40.0%],   [\$43], [7 mo],  [0%],   [100%],  [New basic MTM --- moderate risk],
    [C5],   [747],   [34.7%],   [\$91], [30 mo], [100%], [64%],   [Mid-tenure fiber --- elevated risk],
    [C0],   [1 439], [30.6%],   [\$99], [49 mo], [100%], [52%],   [Long-tenure fiber --- moderate risk],
    [C4],   [1 997], [14.4%],   [\$62], [39 mo], [1%],   [40%],   [Mid-tenure DSL --- low risk],
    [*C2*], [1 520], [*7.4%*],  [\$21], [31 mo], [0%],   [35%],   [Basic no-internet --- very low risk],
  ),
  caption: [GMM component profiles, sorted by churn rate. C1 and C2
  are the extreme cases.],
  kind: table,
)

#figure(
  image("figures/fig_19_gmm_churn.png", width: 96%),
  caption: [Churn rate, monthly charges, and tenure by GMM component.
  Component C1 (new fiber MTM customers) stands out with a 66.3%
  churn rate --- the highest across all clustering solutions.],
)

#figure(
  image("figures/fig_20_gmm_certainty.png", width: 85%),
  caption: [Distribution of max posterior probabilities for churned vs
  retained customers. Churned customers show a heavier tail of
  uncertain membership.],
)

*RQ5 answer:* GMM at k = 6 reveals finer structure than K-Means k = 3.
Component C1 (new fiber MTM customers, churn = 66.3%) is the most
actionable target. The GMM further decomposes the long-tenure fiber segment
(C0 vs C5) and distinguishes new basic-service customers (C3) from the
lowest-risk no-internet segment (C2). The moderate ARI (0.330) against
K-Means confirms that GMM captures genuinely different structure at higher
granularity.

// ═══════════════════════════════════════════════════════════════════════
= RQ6 --- Predicting Contract Type (MTM vs Long-Term)

_What customer and service characteristics predict whether a customer is on
a month-to-month contract, and can we identify at the point of onboarding
who needs a long-term-contract incentive before they become a churn risk?_

*Why this question?* RQ1 established contract type as the single strongest
churn predictor (MTM customers churn at ~43% vs 11% for one-year contracts).
This raises a natural upstream question: what determines contract choice?
If we can predict which *new* customers will default to a month-to-month
contract, we can proactively offer them a long-term discount at signup ---
intercepting the churn risk before it materialises.

*Target:* Binary indicator `Contract_MTM` = 1 (month-to-month, 55.1%) vs
0 (one-year or two-year, 44.9%).

*Feature exclusions:* `Contract` (the target itself), `Churn` (only known
retrospectively --- not available at signup), `TotalCharges` (collinearity).

*Methods:* Logistic Regression (odds ratios), Lasso L1 (feature selection),
shallow Decision Tree (max_depth = 3, actionable rules).

== Logistic Regression

#figure(
  image("figures/fig_26_mtm_lr_cm_roc.png", width: 100%),
  caption: [Logistic Regression for MTM prediction: confusion matrix (left)
  and ROC curve (right). Test AUROC = 0.943 --- substantially higher than
  the churn prediction AUROC (0.833), confirming that contract type is more
  directly encoded in the observable feature set.],
)

The model achieves *test AUROC = 0.943*. Note how much higher this is
compared to churn prediction (0.833): contract type is nearly determined by
observable features, whereas actual churn involves behavioural factors not
captured in this cross-sectional snapshot.

#figure(
  image("figures/fig_27_mtm_odds.png", width: 90%),
  caption: [Odds ratios for month-to-month contract probability. Red bars
  increase MTM odds; blue bars decrease them. `tenure` dominates
  (strong negative: long-tenure customers are on long-term contracts),
  followed by fiber optic (positive) and value-added service add-ons
  (negative).],
)

#figure(
  table(
    columns: (2fr, auto, 1.8fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Feature*], [*Direction*], [*Interpretation*]),
    [`tenure`],                            [↓↓ strongest], [Longer tenure → strongly less likely to be MTM],
    [`InternetService_Fiber optic`],       [↑↑],           [Fiber customers disproportionately choose MTM],
    [`TechSupport_Yes`],                   [↓↓],           [Add-on subscribers commit to longer contracts],
    [`DeviceProtection_Yes`],              [↓],            [Add-on subscribers commit to longer contracts],
    [`PaymentMethod_Electronic check`],    [↑],            [Low-commitment payment → MTM preferred],
    [`PaperlessBilling_Yes`],              [↑],            [Digital-only customers lean toward MTM flexibility],
    [`SeniorCitizen_1`],                   [↑],            [Senior customers more likely to be on MTM],
  ),
  caption: [Key logistic regression odds ratios for MTM contract prediction.],
  kind: table,
)

== Lasso Feature Selection

#figure(
  image("figures/fig_28_mtm_lasso_cv.png", width: 82%),
  caption: [Lasso cross-validation AUROC across C grid. Best C = 1.083
  (near-unpenalised), AUROC = 0.943.],
)

With best *C = 1.083*, Lasso retains *18 of 20 encoded features* and zeroes
out only 2:

#figure(
  table(
    columns: (1.5fr, 1.8fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Zeroed feature*], [*Interpretation*]),
    [`MonthlyCharges`],  [Once service portfolio is controlled for, raw charge level adds no independent information about contract preference],
    [`Partner_Yes`],     [Having a partner does not independently predict contract type when other factors are held constant],
  ),
  caption: [Features zeroed out by Lasso (only 2 of 20 — contract type is well-supported by nearly all features).],
  kind: table,
)

Top Lasso coefficients (standardised):

#figure(
  table(
    columns: (2fr, auto, 1.6fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Feature*], [*Lasso coef.*], [*Direction*]),
    [`InternetService_No`],               [−2.440], [Strongest predictor of long-term contract; no-internet customers almost never choose MTM],
    [`tenure`],                           [−2.079], [Longer tenure strongly predicts long-term contract],
    [`InternetService_Fiber optic`],      [+1.247], [Fiber → MTM preferred],
    [`TechSupport_Yes`],                  [−0.935], [Add-ons → long-term contract],
    [`DeviceProtection_Yes`],             [−0.715], [Add-ons → long-term contract],
    [`PaymentMethod_Electronic check`],   [+0.685], [Low-commitment payment → MTM],
    [`StreamingTV_Yes`],                  [−0.598], [Add-ons → long-term contract],
    [`OnlineSecurity_Yes`],               [−0.592], [Add-ons → long-term contract],
    [`PaperlessBilling_Yes`],             [+0.571], [Digital-only → MTM],
    [`SeniorCitizen_1`],                  [+0.530], [Seniors slightly prefer MTM],
  ),
  caption: [Top Lasso-retained features for MTM prediction.],
  kind: table,
)

== Decision Tree --- Actionable Rules

The depth-3 tree (AUROC = 0.896) translates the model into rules that
front-line staff can apply without a scoring system. Standardised thresholds
convert back to raw units using training-set statistics:
`tenure` mean = 32.42 months, SD = 24.55 months.

#figure(
  raw(block: true,
"|--- tenure ≤ 0.00   [raw: ≤ 32 months]
|   |--- No internet service
|   |   |--- tenure ≤ −1.06  [raw: ≤ 6 months]  →  Predict MTM
|   |   |--- tenure >  −1.06  [raw: > 6 months]   →  Predict Long-Term
|   |--- Has internet service
|   |   →  Predict MTM
|
|--- tenure > 0.00   [raw: > 32 months]
|   |--- tenure ≤ 1.15  [raw: ≤ 61 months]
|   |   |--- No fiber optic  →  Predict Long-Term
|   |   |--- Fiber optic     →  Predict MTM
|   |--- tenure > 1.15  [raw: > 61 months]
|   |   →  Predict Long-Term  (most committed customers)"
  ),
  caption: [Depth-3 decision tree rules for MTM prediction. Two dominant
  patterns: (1) new customers with internet service almost always choose
  MTM; (2) among mid-tenure customers, fiber subscribers remain on MTM
  while non-fiber customers commit to long-term contracts.],
)

#figure(
  image("figures/fig_29_mtm_dt.png", width: 85%),
  caption: [Decision tree feature importances for MTM prediction. `tenure`
  accounts for the majority of the tree's splitting power, followed by
  internet service tier.],
)

== Model Comparison

#figure(
  table(
    columns: (2fr, auto),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*Model*], [*Test AUROC*]),
    [Decision Tree (depth = 3)],      [0.896],
    [Logistic Regression],            [*0.943*],
    [Lasso LR (best C = 1.083)],      [*0.943*],
  ),
  caption: [RQ6 model comparison. LR and Lasso achieve the same AUROC;
  the Lasso barely regularises (C near 1) because almost all features
  are genuinely informative.],
  kind: table,
)

*RQ6 answer:* Contract type is highly predictable from observable features
(AUROC 0.943 vs 0.833 for churn). *Tenure* is overwhelmingly the strongest
signal: new customers almost universally default to month-to-month. After
controlling for tenure, *fiber optic* service independently increases MTM
probability while *value-added service subscriptions* (Tech Support, Device
Protection, Streaming, Online Security) decrease it --- customers who invest
in a rich service bundle are more willing to commit long-term. The DT rules
provide a concrete screening criterion: *new customers on fiber internet
without add-on services* should be flagged at signup for a proactive
long-term contract offer, as they match the highest-risk profile from RQ1
(Cluster 0, churn = 45%).

// ═══════════════════════════════════════════════════════════════════════
= Conclusions & Limitations

== Summary of Findings

#figure(
  table(
    columns: (auto, 1fr),
    fill: (_, y) => if y == 0 { luma(220) }
                    else if calc.odd(y) { luma(247) }
                    else { white },
    table.header([*RQ*], [*Key Finding*]),
    [RQ1], [Contract type and tenure are the strongest churn predictors. Two-year contracts reduce churn odds by the largest margin; fiber optic internet is the top positive risk factor. Gradient Boosting achieves the best AUROC (0.840); all five models agree on the risk factor ranking.],
    [RQ2], [K-Means k = 3 identifies three actionable segments: "New High-Risk" (45% churn), "Basic Loyal" (7% churn), and "Established High-Value" (15% churn, \$4,623 CLV at risk).],
    [RQ3], [Monthly charges are an almost perfectly additive pricing schedule (R² = 0.999). Each add-on contributes a fixed, precisely estimated amount. Contract length does not affect monthly price.],
    [RQ4], [The shallow DT distils the churn signal into one rule: new customers (≤ 16 months) on fiber optic churn. Gradient Boosting tops the leaderboard (0.840); the marginal gain over logistic regression is modest (0.7 pp).],
    [RQ5], [GMM at k = 6 provides soft probabilistic assignments. Component C1 (new fiber MTM, churn = 66.3%) is the highest-risk identifiable segment. Uncertain membership concentrates among churners.],
    [RQ6], [Contract type is highly predictable (AUROC = 0.943). Tenure dominates; fiber optic increases MTM probability; add-on services decrease it. DT rule: new + fiber + no add-ons → flag for long-term contract offer at signup.],
  ),
  caption: [Summary of findings across all five research questions.],
  kind: table,
)

== Limitations

+ *No causal claims.* All findings are associations from observational
  cross-sectional data. The fact that fiber optic customers churn more does
  not imply that fiber causes churn --- confounding factors (competitive
  alternatives, geographic market structure) are unobserved.

+ *Class imbalance.* With 26.6% churn, classifiers optimised for accuracy
  tend to suppress the minority class. We use `class_weight='balanced'` for
  logistic regression and report AUROC (threshold-free). Future work could
  apply SMOTE or cost-sensitive learning more systematically.

+ *`TotalCharges` excluded.* Near-perfect collinearity ($r = 0.9996$) with
  `tenure × MonthlyCharges` requires exclusion from all models, omitting
  the long-run revenue dimension as a direct predictor.

+ *Clustering sensitivity.* Silhouette scores are computed in the PCA-5
  space. Different distance metrics or preprocessing choices could shift
  the optimal k. The k = 3 solution is preferred on substantive grounds
  (distinct churn profiles), not solely on the silhouette criterion.

+ *Temporal structure ignored.* Tenure is treated as a static snapshot.
  Customer behaviour evolves over time; a survival analysis or longitudinal
  panel model would better capture the temporal dynamics of churn.

#v(2em)
#align(center)[
  #text(size: 9pt, style: "italic")[
    All analysis performed in Python 3.14 using scikit-learn, statsmodels,
    matplotlib, and seaborn.
  ]
]
