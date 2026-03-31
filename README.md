# ctDNA Mutect2 Benchmark Pipeline

This repository reproduces and stress-tests somatic variant calling on ultra-deep ctDNA-like data based on:

**Gong et al.**
*Ultra-deep sequencing data from a liquid biopsy proficiency study demonstrating analytic validity*
https://pmc.ncbi.nlm.nih.gov/articles/PMC9008010

---

## Executive Summary

I evaluated Mutect2 performance on ultra-deep targeted sequencing data (Gong et al.) across increasing read depths (5M–200M) to assess sensitivity for low-frequency (ctDNA-like) variant detection.

Despite substantial increases in sequencing depth, recovery of known low-AF variants remained limited due to uneven coverage, extremely high duplication, and the absence of UMI-aware processing. Tumor-only calling retained partial signal but produced noise, while use of a pseudo-matched normal nearly eliminated true positives, demonstrating the risk of improper normal selection.

Overall, this analysis shows that standard somatic pipelines are insufficient for ctDNA applications without UMI integration and careful experimental design.

---

## Note on Public Data Reuse

This analysis highlights a practical limitation when working with publicly deposited sequencing data. Although the original assay incorporated UMIs, these were not retained in the FASTQ files available through SRA, and no explicit metadata described how reads had been processed prior to submission.

More consistent inclusion of processing metadata (e.g., whether UMIs are present, stripped, or relocated; whether consensus reads have been generated; and preprocessing steps applied prior to deposition) would improve reproducibility and allow users to better assess dataset suitability before incurring the cost of large-scale downloads.

---

## Overview

This project evaluates somatic variant detection performance in ultra-deep targeted sequencing data derived from a liquid biopsy proficiency study.

I used publicly available data from:

Gong et al. — Ultra-deep sequencing data from a liquid biopsy proficiency study demonstrating analytic validity  
https://pmc.ncbi.nlm.nih.gov/articles/PMC9008010/

The goal was to:

1. Build an end-to-end ctDNA analysis pipeline from raw FASTQ  
2. Assess how depth impacts variant detection in targeted panels  
3. Compare tumor-only vs pseudo-matched normal calling  
4. Benchmark recovery of known truth variants  
5. Identify limitations of non-UMI-aware workflows  

This serves as a foundation for a follow-up UMI-aware pipeline.

---

## Dataset

I selected two samples from the study:

| Sample | Description | SRA |
|--------|-------------|-----|
| Bf     | Non-cancer control (0:1) | SRR13385590 |
| Ef     | Tumor mixture (~1:24)   | SRR13385577 |

- Platform: Illumina NovaSeq 6000  
- Panel: TruSight Tumor 170 (TST170)  
- Library included UMIs but they were not contained in the SRA  

In total the two runs contain ~1.4 billion read pairs. Subsampling was used to explore depth effects.

---

## Environment

- AWS EC2 (Ubuntu)  
- ~1 TB EBS storage  
- Approximate cost: ~$50 over several days  

---

## Repo structure
```
└── ctdna
    ├── data
    ├── old
    ├── ref
    ├── results
    └── scripts
```
Note that scripts exist to enable the user to do all file retrieval and processing themselves since most files are very large.

Key results files of manageable size (summaries, fragment size graphs etc) exist as part of the repo and can be visualized without running anything. 

---
## Pipeline

This pipeline:

- Downloads SRA data (Bf and Ef samples)  
- Subsamples reads to multiple depths (5M → 200M)  
- Aligns reads and performs QC  
- Runs Mutect2 (tumor-only and pseudo tumor-normal)  
- Benchmarks results against a known truth set  

This is a **benchmark / stress-test pipeline**, not a production ctDNA workflow.

To reiterate: the workflow is not UMI-aware since UMIs were removed from the sequences prior to SRA deposition. Future work will address this.

---

## Results Summary

Analysis was performed across increasing sequencing depths (5M → 200M reads).

### Truth Recovery (Tumor-only, mix124)

Two definitions were evaluated:

- **ALL** = all records in filtered VCF  
- **PASS** = high-confidence calls after Mutect2 filtering  

#### ALL (filtered VCF)

| Depth | Calls Unique | Truth Missed | Truth Recovered |
|------|-------------|-------------|----------------|
| 5M   | 336 | 457 | 133 |
| 20M  | 331 | 457 | 133 |
| 100M | 416 | 458 | 132 |
| 200M | 456 | 457 | 133 |

Observation:

- Truth recovery remained essentially **constant (~132–133 variants)** across all depths  
- Increasing depth did **not improve recovery at the candidate level**

#### PASS (high-confidence calls)

| Depth | Calls Unique | Truth Missed | Truth Recovered |
|------|-------------|-------------|----------------|
| 5M   | 6  | 590 | 0 |
| 20M  | 13 | 590 | 0 |
| 100M | 39 | 590 | 0 |
| 200M | 47 | 590 | 0 |

Observation:

- PASS calls increase with depth  
- **No truth variants survive PASS filtering at any depth**


## Duplicate Burden

Duplicate marking revealed extremely high redundancy:

- mix01_200M: **~93% duplicates**  
- mix124_200M: **~96% duplicates**

Duplicates were marked (not removed), but these values indicate that most reads represent repeated observations of the same original molecules.

Although this was observed early in QC, analysis was continued to assess whether increased depth could compensate in a non-UMI-aware workflow. It did not.


## Coverage and Depth

Even at high sequencing depths with 200 million reads:

- Coverage across the target region remained uneven  
- ~47.5% of bases reached ≥500x  
- ~0.5% if bases reached ≥1000x  

Implication:

- At 2% AF and 500x → ~10 supporting reads  
- Many loci remain below reliable detection thresholds  

---

## Tumor-Normal (Pseudo-Normal)

Using mix01 as a pseudo-normal:

- Shared true positives: **~0–1**  
- Majority of known variants missed  

Interpretation:

- Shared signal between samples was removed  
- Demonstrates over-filtering when using inappropriate normal samples  

---
## Interpretation of Detection Failure

Two consistent patterns emerge when comparing candidate-level (ALL) and filtered (PASS) calls:

Candidate recovery plateaus
Across all depths (5M → 200M), recovery of known truth variants remains essentially unchanged (~132–133 variants). Increasing sequencing depth does not improve detection of true variants, even before filtering.
PASS calls increase, but not accuracy
The number of PASS calls increases with depth (6 → 47), but none overlap the truth set at any depth.

# Takeaway

Increasing nominal sequencing depth increases call volume, but does not improve recovery of low-frequency truth variants.

Truth variants are detectable at the candidate level but fail to accumulate enough evidence to pass filtering. At the same time, additional depth introduces more high-confidence calls that do not correspond to known variants.

# Implication

This behavior is consistent with a limitation in usable signal rather than raw read count. In practice, this often reflects:

high duplication (limited unique molecule sampling)
lack of UMI-based error correction

These factors reduce the effective evidence available for low-frequency variant detection, even at very high nominal depth.

---

## Context: Duplication and UMI Impact

Targeted ctDNA sequencing is inherently characterized by high duplication rates due to low DNA input and extensive PCR amplification. Reported workflows frequently exhibit duplication rates exceeding 60–90%, particularly in ultra-deep sequencing experiments. In this analysis, duplicate rates of ~93–96% were observed, consistent with this expected behavior.

In standard (non-UMI) pipelines, these duplicates do not contribute additional independent evidence and therefore inflate nominal depth without increasing effective molecular coverage. In contrast, UMI-based approaches group duplicate reads originating from the same molecule and collapse them into consensus sequences, substantially reducing error rates (to ~10⁻⁵–10⁻⁷) and enabling reliable detection of very low-frequency variants.

As a result, the absence of UMI information in this dataset meant that increased sequencing depth did not translate into increased effective sensitivity, limiting variant detection despite ultra-deep sequencing.

---

## Key Takeaways

1. **Depth alone does not improve low-AF detection**
2. **High duplication severely limits effective coverage**
3. **Tumor-only retains partial signal but is noisy**
4. **Pseudo-normal calling removes true signal**
5. **UMI-aware processing is required for ctDNA sensitivity**

---

## Overall Conclusion

Increasing sequencing depth without UMI-aware processing did not improve recovery of low-frequency variants.

Recovery plateaued at the candidate level (~133 variants) and dropped to zero at the PASS level.

Performance was constrained by:

- Extremely high duplication (low molecular complexity)  
- Uneven coverage  
- Lack of UMI-based error suppression  

Under these conditions, Mutect2 is unable to reliably detect low-frequency ctDNA variants despite very high nominal sequencing depth.

---

## Next Steps

- Add UMI-aware processing (fgbio, Sentieon, etc.)  
- Convert pipeline to Nextflow  
- Evaluate alternative variant callers  
