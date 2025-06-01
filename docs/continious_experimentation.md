# Continuous Experimentation: Impact of Displaying Model Confidence Scores on User Corrections

**Services Involved:** `app-frontend`, `app-service`, `model-service` (both `stable` and `canary` versions)



## 1. Introduction and Experiment Rationale

Our application allows users to submit reviews for restaurants. A core feature involves our `model-service` classifying these reviews as either positive or negative. This prediction, an integer value representing the sentiment, is processed by the `app-service` and then presented to the user in the `app-frontend` (as "positive" or "negative"). Users currently have the ability to manually correct this prediction if they feel it doesn't align with their intended sentiment.

We are investigating a potential enhancement: displaying the confidence score associated with the model's prediction. The underlying sentiment prediction model itself will **not** be changed for this experiment. Our goal is to determine if providing this additional piece of information to the user influences their tendency to make manual corrections.

This document outlines the experiment designed to test this feature.

## 2. The Base Experience (Control Group - `stable` version)

The current, established user experience is served by the `stable` versions of our services:

1.  A user submits a restaurant review text via the `app-frontend-stable`.
2.  The `app-frontend-stable` sends this text to the `app-service-stable`.
3.  The `app-service-stable` forwards the request to the `model-service-stable`.
4.  The `model-service-stable` (using our existing, unchanged sentiment analysis model) predicts the sentiment and returns it as an integer (e.g., `0` for negative, `1` for positive) along with any other standard data, but **no confidence score is exposed**.
5.  The `app-service-stable` relays this integer sentiment prediction back to the `app-frontend-stable`.
6.  The `app-frontend-stable` interprets the integer (e.g., `0` -> "negative", `1` -> "positive") and displays the predicted sentiment to the user.
7.  If the user disagrees with the displayed prediction, they can use an interface element to correct it. Each correction is logged.

Users routed to this `stable` stack will form the **control group** for our experiment and will not see any confidence scores.

## 3. The New Feature: Introducing Confidence Scores (Experimental Group - `canary` version)

For this experiment, we are deploying `canary` versions of our services. These versions are identical to their `stable` counterparts except for the handling and display of model confidence scores. The core sentiment prediction logic of the `model-service` remains unchanged.

The modifications are as follows:

*   **`model-service-canary`:**
    *   **Change:** While still returning the sentiment as an integer, this version has been updated to also return the confidence score (a float, e.g., `0.0` to `1.0`) associated with that prediction. For example, the response might be `{"prediction": 1, "prediction_confidence": 0.92}`.

*   **`app-service-canary`:**
    *   **Change:** This service has been updated to receive both the integer sentiment and the confidence score from `model-service-canary`. It then passes both pieces of information in its API response to `app-frontend-canary`.

*   **`app-frontend-canary`:**
    *   **Change:** This version is modified to receive and parse the confidence score from the `app-service-canary` response. It will still interpret the sentiment integer into a human-readable string (e.g., "positive," "negative") but will now also display the confidence score. For instance, a user might see: "positive (92% confidence)".

Users routed to this `canary` stack via Istio's traffic management will form our **experimental group**.

## 4. Hypothesis

We propose the following falsifiable hypothesis:

*   **Primary Hypothesis (H1):** *Displaying the model's confidence score will lead to an **increase** in the overall rate of manual corrections made by users. This is anticipated because transparency into the model's certainty (especially when low) will empower users to correct predictions they perceive as inaccurate or weakly supported, which they might have otherwise let pass.*
    *   **Rationale:** When users see that the model itself is not highly confident in a prediction (e.g., "Positive, 60% confidence"), and this prediction mismatches their own assessment, they may feel more justified or encouraged to make a correction. While high-confidence scores might deter some corrections, we suspect the effect of low-confidence scores encouraging corrections will be more dominant, leading to a net increase. This could ultimately improve the quality of user-validated data.

*   **Null Hypothesis (H0):** *Displaying the confidence score will have no statistically significant impact on the overall rate of user-initiated manual corrections.*

## 5. Metrics for Evaluation

To test our hypothesis, we will monitor the following metrics. All metrics will be tagged by service version (`stable` or `canary`).

### 5.1. Primary Metrics

1.  **`user_manual_corrections_total` (Counter):**
    *   **Description:** Incremented each time a user manually corrects the sentiment prediction.
    *   **Tags:** `version` (`stable`/`canary`), `service` (`app-frontend` or `app-service`).
    *   **Purpose:** Direct measure of the behavior under study.

2.  **`predictions_served_total` (Counter):**
    *   **Description:** Incremented for every sentiment prediction served to a user.
    *   **Tags:** `version` (`stable`/`canary`), `service` (`model-service` or `app-service`).
    *   **Purpose:** Denominator for calculating rates.

3.  **`correction_rate` (Gauge - Calculated):**
    *   **Description:** `user_manual_corrections_total / predictions_served_total` for each version.
    *   **Purpose:** The key comparative metric. We expect `correction_rate_canary > correction_rate_stable` if H1 is true.

## 6. Experiment Setup & Traffic Management

*(This section remains largely the same as your previous version, detailing canary deployment, traffic splitting with Istio, and sticky sessions using the cookie method.)*

*   **Canary Deployment:** The `canary` versions of `app-frontend`, `app-service`, and `model-service` will be deployed alongside their `stable` counterparts. Image tags for these canary deployments will be `:canary`, managed via our CI/CD pipeline (e.g., a manually triggered GitHub Action on a feature branch).
*   **Traffic Splitting:** We will use Istio to manage traffic. Initially, a small percentage of user traffic (e.g., 10%) will be directed to the `canary` stack, while the remaining 90% will continue to use the `stable` stack. This will be configured using Istio `VirtualService` and `DestinationRule` resources for each of the three services (`app-frontend`, `app-service`, `model-service`) to ensure consistent routing (i.e., a user hitting `app-frontend-canary` will use `app-service-canary` and `model-service-canary`).

*   **Sticky Sessions:** To ensure a consistent user experience and the integrity of our experimental data, sticky sessions will be implemented for the `app-frontend`. This is achieved via an Istio `VirtualService` for `app-frontend` that inspects and sets a cookie:
    *   If a request has a cookie `app-frontend-version=stable`, it's routed to the `stable` `app-frontend` subset.
    *   If a request has a cookie `app-frontend-version=canary`, it's routed to the `canary` `app-frontend` subset.
    *   For new users without this cookie, the `VirtualService` routes them to either the `stable` or `canary` subset based on the defined weights (e.g., 90% stable, 10% canary for the start of the experiment) and adds a `Set-Cookie: app-frontend-version=<chosen_version>` header to the response. This ensures subsequent requests from that user are "stuck" to the initially assigned version for the duration of the cookie's validity.

## 7. Data Collection & Monitoring

*   **Prometheus:** Our Kubernetes cluster's Prometheus instance will scrape the metrics detailed above.
*   **Grafana:** A dedicated Grafana dashboard will be created.

## 8. Decision Process

The experiment will run for a defined period (e.g., 1-2 weeks) to gather sufficient data. The decision will be based on:

1.  **Primary Outcome (Supports H1):**
    *   A statistically significant **increase** in the overall `correction_rate` for the `canary` version compared to the `stable` version.
    *   Analysis of `canary_low_confidence_corrections_total` vs. `canary_high_confidence_corrections_total` (normalized by predictions served at those confidence levels) should ideally show that the increase in corrections is more pronounced for low-confidence predictions.
    *   No significant degradation in system health metrics.
    *   **Action:** If this outcome is observed and deemed beneficial (e.g., leading to better quality feedback, identifying model weaknesses), proceed with a gradual rollout of the feature.

2.  **Neutral Outcome (Supports H0):**
    *   No statistically significant difference in the `correction_rate` between `stable` and `canary`.
    *   No adverse impact on system health.
    *   **Action:** Discuss if the feature offers other qualitative benefits (e.g., perceived transparency). May decide to roll out if low risk, or iterate/remove if no clear benefit.

3.  **Negative Outcome (Unexpected Result/System Issues):**
    *   A statistically significant *decrease* in the `correction_rate` for `canary` (contrary to H1, but still a change).
    *   Or, a significant increase in error rates or unacceptable latency degradation for `canary`.
    *   Or, overall correction rate increases, but analysis shows users are *also* correcting high-confidence predictions more often, suggesting confusion.
    *   **Action:** Roll back `canary` changes. Investigate the cause. Re-evaluate the feature's design or premise.

**Timeline for Review:** (Same as before)

## 9. Grafana Dashboard Visualization

A Grafana dashboard will be central. Key panels will include:

---

**[Screenshot Placeholder: Grafana Dashboard for Confidence Score Experiment]**
*A screenshot showing key comparative charts.*
*   *Time-series graph: `Correction Rate` (stable vs. canary).*

---

**Key Panel Descriptions:**

1.  **Correction Rate Comparison (`stable` vs. `canary`):**
    *   **Visualization:** Line chart.
    *   **Query Idea (PromQL):**
        ```promql
        (sum(rate(user_manual_corrections_total{job=~"app-frontend|app-service"}[5m])) by (version))
        /
        (sum(rate(predictions_served_total{job=~"model-service|app-service"}[5m])) by (version))
        ```
    *   **Purpose:** The primary indicator for comparing user correction behavior.

## 10. Conclusion and Next Steps

This experiment aims to understand how displaying model confidence scores affects user engagement with our sentiment correction feature. By testing the hypothesis that this transparency will lead to more active (and potentially more numerous) corrections, especially for less certain predictions, we hope to gather insights that can improve both user experience and the quality of feedback data.