# KONAET / measured benchmark

Source: `4d0e7532f668bbd59d3e952404a8ab8dc30cd592`

Benchmark SHA-256: `b9fef1c47ef6d930008e984cc6cfd00015d4bb600694b4de5ea0f05b4234f7aa`

Model bundle SHA-256: `807904debf4c2a3a4145c608562dd29222a8bfaeab00ed7fda03e2c1b5f1b007`

Generated from counts in this package. BA includes abstentions as unresolved cases. Bootstrap intervals are conditional on each series.

| Suite | Method | BA (%) | Recall (%) | FPR (%) | Coverage (%) |
| --- | --- | ---: | ---: | ---: | ---: |
| hard_synthetic_locked | KONAET_FP32 | 82.57 | 73.83 | 8.69 | 100.00 |
| hard_synthetic_locked | KONAET_INT8 | 81.54 | 75.59 | 12.50 | 100.00 |
| hard_synthetic_locked | AnomalyNet_FP32 | 73.10 | 77.05 | 30.86 | 100.00 |
| hard_synthetic_locked | AnomalyNet_INT8 | 73.49 | 77.44 | 30.47 | 100.00 |
| hard_synthetic_locked | max_difference | 78.56 | 58.01 | 0.88 | 100.00 |
| hard_synthetic_locked | detrended_spread | 68.12 | 37.60 | 1.37 | 100.00 |
| hard_synthetic_locked | ewma_residual | 81.15 | 63.09 | 0.78 | 100.00 |
| hard_synthetic_locked | KONAET_CONTEXT | 76.56 | 53.61 | 0.49 | 100.00 |
| easy_synthetic | KONAET_FP32 | 99.71 | 99.41 | 0.00 | 100.00 |
| easy_synthetic | KONAET_INT8 | 99.71 | 99.41 | 0.00 | 100.00 |
| easy_synthetic | AnomalyNet_FP32 | 99.90 | 99.80 | 0.00 | 100.00 |
| easy_synthetic | AnomalyNet_INT8 | 99.90 | 99.80 | 0.00 | 100.00 |
| easy_synthetic | max_difference | 87.50 | 75.00 | 0.00 | 100.00 |
| easy_synthetic | detrended_spread | 87.40 | 74.80 | 0.00 | 100.00 |
| easy_synthetic | ewma_residual | 93.95 | 87.89 | 0.00 | 100.00 |
| easy_synthetic | KONAET_CONTEXT | 100.00 | 100.00 | 0.00 | 100.00 |
| strong_noise_shift | KONAET_FP32 | 75.29 | 82.03 | 31.45 | 99.90 |
| strong_noise_shift | KONAET_INT8 | 72.95 | 82.23 | 36.33 | 99.90 |
| strong_noise_shift | AnomalyNet_FP32 | 66.70 | 86.13 | 52.73 | 99.90 |
| strong_noise_shift | AnomalyNet_INT8 | 66.70 | 86.13 | 52.73 | 99.90 |
| strong_noise_shift | max_difference | 66.21 | 82.23 | 49.80 | 99.90 |
| strong_noise_shift | detrended_spread | 70.80 | 58.79 | 17.19 | 99.90 |
| strong_noise_shift | ewma_residual | 71.29 | 83.98 | 41.41 | 99.90 |
| strong_noise_shift | KONAET_CONTEXT | 74.90 | 67.38 | 17.58 | 99.90 |
| machine_temperature_system_failure.csv | KONAET_FP32 | 72.07 | 58.45 | 14.32 | 100.00 |
| machine_temperature_system_failure.csv | KONAET_INT8 | 77.82 | 70.42 | 14.79 | 100.00 |
| machine_temperature_system_failure.csv | AnomalyNet_FP32 | 86.45 | 92.25 | 19.36 | 100.00 |
| machine_temperature_system_failure.csv | AnomalyNet_INT8 | 85.63 | 90.85 | 19.59 | 100.00 |
| machine_temperature_system_failure.csv | max_difference | 52.74 | 7.75 | 2.26 | 100.00 |
| machine_temperature_system_failure.csv | detrended_spread | 50.11 | 2.11 | 1.88 | 100.00 |
| machine_temperature_system_failure.csv | ewma_residual | 50.35 | 2.11 | 1.41 | 100.00 |
| machine_temperature_system_failure.csv | KONAET_CONTEXT | 50.30 | 2.11 | 1.51 | 100.00 |
| ambient_temperature_system_failure.csv | KONAET_FP32 | 48.97 | 80.22 | 82.28 | 100.00 |
| ambient_temperature_system_failure.csv | KONAET_INT8 | 48.18 | 80.22 | 83.86 | 100.00 |
| ambient_temperature_system_failure.csv | AnomalyNet_FP32 | 50.40 | 97.80 | 96.99 | 100.00 |
| ambient_temperature_system_failure.csv | AnomalyNet_INT8 | 50.95 | 98.90 | 96.99 | 100.00 |
| ambient_temperature_system_failure.csv | max_difference | 50.00 | 0.00 | 0.00 | 100.00 |
| ambient_temperature_system_failure.csv | detrended_spread | 53.99 | 12.09 | 4.11 | 100.00 |
| ambient_temperature_system_failure.csv | ewma_residual | 49.45 | 0.00 | 1.11 | 100.00 |
| ambient_temperature_system_failure.csv | KONAET_CONTEXT | 50.00 | 0.00 | 0.00 | 100.00 |
| cpu_utilization_asg_misconfiguration.csv | KONAET_FP32 | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | KONAET_INT8 | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | AnomalyNet_FP32 | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | AnomalyNet_INT8 | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | max_difference | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | detrended_spread | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | ewma_residual | 0.00 | 0.00 | 0.00 | 0.00 |
| cpu_utilization_asg_misconfiguration.csv | KONAET_CONTEXT | 0.00 | 0.00 | 0.00 | 0.00 |
| ec2_request_latency_system_failure.csv | KONAET_FP32 | 38.37 | 76.74 | 100.00 | 97.49 |
| ec2_request_latency_system_failure.csv | KONAET_INT8 | 38.37 | 76.74 | 100.00 | 97.49 |
| ec2_request_latency_system_failure.csv | AnomalyNet_FP32 | 38.37 | 76.74 | 100.00 | 97.49 |
| ec2_request_latency_system_failure.csv | AnomalyNet_INT8 | 38.37 | 76.74 | 100.00 | 97.49 |
| ec2_request_latency_system_failure.csv | max_difference | 44.37 | 9.30 | 20.56 | 97.49 |
| ec2_request_latency_system_failure.csv | detrended_spread | 46.48 | 0.00 | 7.04 | 97.49 |
| ec2_request_latency_system_failure.csv | ewma_residual | 57.01 | 16.28 | 2.25 | 97.49 |
| ec2_request_latency_system_failure.csv | KONAET_CONTEXT | 48.70 | 16.28 | 18.87 | 97.49 |
| nyc_taxi.csv | KONAET_FP32 | 49.61 | 99.22 | 100.00 | 100.00 |
| nyc_taxi.csv | KONAET_INT8 | 49.67 | 99.22 | 99.89 | 100.00 |
| nyc_taxi.csv | AnomalyNet_FP32 | 50.00 | 100.00 | 100.00 | 100.00 |
| nyc_taxi.csv | AnomalyNet_INT8 | 50.00 | 100.00 | 100.00 | 100.00 |
| nyc_taxi.csv | max_difference | 51.55 | 3.10 | 0.00 | 100.00 |
| nyc_taxi.csv | detrended_spread | 47.89 | 0.78 | 5.00 | 100.00 |
| nyc_taxi.csv | ewma_residual | 42.37 | 12.40 | 27.67 | 100.00 |
| nyc_taxi.csv | KONAET_CONTEXT | 51.94 | 3.88 | 0.00 | 100.00 |
| ec2_cpu_utilization_5f5533.csv | KONAET_FP32 | 48.29 | 90.00 | 93.43 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | KONAET_INT8 | 47.43 | 90.00 | 95.14 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | AnomalyNet_FP32 | 46.14 | 92.00 | 99.71 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | AnomalyNet_INT8 | 46.14 | 92.00 | 99.71 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | max_difference | 56.43 | 14.00 | 1.14 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | detrended_spread | 50.00 | 0.00 | 0.00 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | ewma_residual | 50.00 | 0.00 | 0.00 | 99.00 |
| ec2_cpu_utilization_5f5533.csv | KONAET_CONTEXT | 33.43 | 54.00 | 87.14 | 99.00 |

Deployment: **RESEARCH_ONLY**. No new independent-device holdout or physical bench validation is claimed. See model-qualification.json for proposed targets and each external case.
