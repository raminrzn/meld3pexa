# meld3pexa

**MELD 3.0** as a ModelsCloud service: a liver disease severity score and the
predicted 90-day survival on the transplant waitlist.

Kim WR, et al. *Gastroenterology.* 2021;161(6):1887–1895.
[doi:10.1053/j.gastro.2021.08.050](https://doi.org/10.1053/j.gastro.2021.08.050)

## Inputs

| Field | Coding |
|---|---|
| `sex` | `"male"` / `"female"` |
| `bilirubin` | mg/dL (µmol/L if `units = "si"`) |
| `sodium` | mmol/L |
| `inr` | ratio |
| `creatinine` | mg/dL (µmol/L if `units = "si"`) |
| `albumin` | g/dL (g/L if `units = "si"`) |
| `units` | optional: `"conventional"` (default) or `"si"` |

Returns `score` (rounded, not capped at 40), `raw_score`, `survival_90d` and
`mortality_90d` (0–1).

The published bounds are applied: bilirubin, INR and creatinine ≥ 1.0;
creatinine ≤ 3.0; sodium 125–137; albumin 1.5–3.5. OPTN's allocation rule
setting creatinine to 3.0 for patients on dialysis is not included; pass
`creatinine = 3` for those patients.

## Validation

Matches MDCalc's MELD 3.0 calculator on 9 patients (scores 6–41) for both
the score and 90-day survival.

Only the 90-day horizon is provided. The paper prints its baseline survival
in the main text; the other horizons appear only in the supplement, which
could not be checked independently.

## Use

```r
remotes::install_git("https://github.com/raminrzn/meld3pexa", ref = "main")
meld3pexa::model_run(list(sex = "male", bilirubin = 2.5, sodium = 137,
                          inr = 1.4, creatinine = 1.0, albumin = 3.2))
```

For research use. Not a medical device.

## License

GPL-3.
